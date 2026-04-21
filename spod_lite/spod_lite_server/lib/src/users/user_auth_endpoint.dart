import 'dart:convert';
import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:serverpod/serverpod.dart';

import '../emails/email_driver.dart';
import '../generated/protocol.dart';
import 'user_rate_limiter.dart';

const _sessionTtl = Duration(days: 30);
const _codeTtl = Duration(hours: 1);

/// Self-serve end-user auth. Public endpoint — anyone can hit `signUp`
/// and `signIn`. Signing in returns a token that the SDK attaches to
/// subsequent requests; the authentication handler resolves it into a
/// `user` scope for rule evaluation.
class UserAuthEndpoint extends Endpoint {
  Future<String> signUp(
    Session session,
    String email,
    String password,
  ) async {
    final normalized = _normalizeEmail(email);
    _validateEmail(normalized);
    _validatePassword(password);

    final existing = await AppUser.db.findFirstRow(
      session,
      where: (u) => u.email.equals(normalized),
    );
    if (existing != null) {
      throw SpodLiteException(
        message: 'An account with that email already exists.',
        code: SpodLiteErrorCode.conflict,
      );
    }

    final hash = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));
    final user = await AppUser.db.insertRow(
      session,
      AppUser(email: normalized, passwordHash: hash),
    );
    return _issueSession(session, user.id!);
  }

  Future<String> signIn(
    Session session,
    String email,
    String password,
  ) async {
    final normalized = _normalizeEmail(email);
    UserSignInRateLimiter.check(normalized);

    final user = await AppUser.db.findFirstRow(
      session,
      where: (u) => u.email.equals(normalized),
    );
    if (user == null || !BCrypt.checkpw(password, user.passwordHash)) {
      UserSignInRateLimiter.recordFailure(normalized);
      session.log('[UserAuth] failed sign-in for $normalized',
          level: LogLevel.warning);
      throw SpodLiteException(
        message: 'Invalid email or password.',
        code: SpodLiteErrorCode.unauthorized,
      );
    }
    UserSignInRateLimiter.recordSuccess(normalized);
    return _issueSession(session, user.id!);
  }

  Future<AppUser?> me(Session session, String token) async {
    final user = await _resolveUser(session, token);
    if (user == null) return null;
    return user.copyWith(passwordHash: '');
  }

  Future<void> signOut(Session session, String token) async {
    await AppSession.db
        .deleteWhere(session, where: (s) => s.token.equals(token));
  }

  /// Generates a verification code, persists it on the caller's account,
  /// and emails it. Idempotent if the user is already verified.
  Future<void> requestEmailVerification(
    Session session,
    String token,
  ) async {
    final user = await _resolveUser(session, token);
    if (user == null) {
      throw SpodLiteException(
        message: 'Sign-in required.',
        code: SpodLiteErrorCode.unauthorized,
      );
    }
    if (user.emailVerified) return;

    final code = _newCode();
    await AppUser.db.updateRow(
      session,
      user.copyWith(
        emailVerificationCode: code,
        emailVerificationExpiresAt: DateTime.now().toUtc().add(_codeTtl),
      ),
    );
    await EmailService.instance.send(EmailMessage(
      to: user.email,
      subject: 'Verify your email',
      body: 'Your verification code is $code.\n\n'
          'It expires in ${_codeTtl.inMinutes} minutes.',
    ));
  }

  /// Confirms an email-verification code. Marks the account verified and
  /// clears the code on success. Throws on invalid or expired codes.
  Future<void> verifyEmail(
    Session session,
    String token,
    String code,
  ) async {
    final user = await _resolveUser(session, token);
    if (user == null) {
      throw SpodLiteException(
        message: 'Sign-in required.',
        code: SpodLiteErrorCode.unauthorized,
      );
    }
    if (user.emailVerified) return;
    _checkCode(
      provided: code,
      expected: user.emailVerificationCode,
      expiresAt: user.emailVerificationExpiresAt,
    );
    await AppUser.db.updateRow(
      session,
      user.copyWith(
        emailVerified: true,
        emailVerificationCode: null,
        emailVerificationExpiresAt: null,
      ),
    );
  }

  /// Sends a password-reset code to the account at [email] if one exists.
  /// Always returns normally so the endpoint can't be used for user
  /// enumeration.
  Future<void> requestPasswordReset(
    Session session,
    String email,
  ) async {
    final normalized = _normalizeEmail(email);
    final user = await AppUser.db.findFirstRow(
      session,
      where: (u) => u.email.equals(normalized),
    );
    if (user == null) return;

    final code = _newCode();
    await AppUser.db.updateRow(
      session,
      user.copyWith(
        passwordResetCode: code,
        passwordResetExpiresAt: DateTime.now().toUtc().add(_codeTtl),
      ),
    );
    await EmailService.instance.send(EmailMessage(
      to: user.email,
      subject: 'Reset your password',
      body: 'Your password-reset code is $code.\n\n'
          'It expires in ${_codeTtl.inMinutes} minutes.\n\n'
          'If you didn\'t request a reset, ignore this email.',
    ));
  }

  /// Confirms a password-reset code and sets a new password. Invalidates
  /// every existing session on the account so a stolen session can't
  /// survive a reset.
  Future<void> confirmPasswordReset(
    Session session,
    String email,
    String code,
    String newPassword,
  ) async {
    final normalized = _normalizeEmail(email);
    _validatePassword(newPassword);

    final user = await AppUser.db.findFirstRow(
      session,
      where: (u) => u.email.equals(normalized),
    );
    if (user == null) {
      throw SpodLiteException(
        message: 'Invalid or expired reset code.',
        code: SpodLiteErrorCode.invalidInput,
      );
    }
    _checkCode(
      provided: code,
      expected: user.passwordResetCode,
      expiresAt: user.passwordResetExpiresAt,
      genericMessage: 'Invalid or expired reset code.',
    );

    final hash = BCrypt.hashpw(newPassword, BCrypt.gensalt(logRounds: 12));
    await session.db.transaction((tx) async {
      await AppUser.db.updateRow(
        session,
        user.copyWith(
          passwordHash: hash,
          passwordResetCode: null,
          passwordResetExpiresAt: null,
        ),
        transaction: tx,
      );
      await AppSession.db.deleteWhere(
        session,
        where: (s) => s.appUserId.equals(user.id!),
        transaction: tx,
      );
    });
  }

  void _checkCode({
    required String provided,
    required String? expected,
    required DateTime? expiresAt,
    String genericMessage = 'Invalid or expired code.',
  }) {
    if (expected == null ||
        expiresAt == null ||
        provided.trim().isEmpty ||
        provided != expected) {
      throw SpodLiteException(
        message: genericMessage,
        code: SpodLiteErrorCode.invalidInput,
      );
    }
    if (expiresAt.isBefore(DateTime.now().toUtc())) {
      throw SpodLiteException(
        message: genericMessage,
        code: SpodLiteErrorCode.invalidInput,
      );
    }
  }

  String _newCode() {
    final n = Random.secure().nextInt(1000000);
    return n.toString().padLeft(6, '0');
  }

  Future<String> _issueSession(Session session, int userId) async {
    final token = _randomToken();
    await AppSession.db.insertRow(
      session,
      AppSession(
        token: token,
        appUserId: userId,
        expiresAt: DateTime.now().toUtc().add(_sessionTtl),
      ),
    );
    return token;
  }

  Future<AppUser?> _resolveUser(Session session, String token) async {
    if (token.isEmpty) return null;
    final appSession = await AppSession.db.findFirstRow(
      session,
      where: (s) => s.token.equals(token),
    );
    if (appSession == null) return null;
    if (appSession.expiresAt.isBefore(DateTime.now().toUtc())) {
      await AppSession.db
          .deleteWhere(session, where: (s) => s.token.equals(token));
      return null;
    }
    return AppUser.db.findById(session, appSession.appUserId);
  }
}

String _randomToken() {
  final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
  return base64UrlEncode(bytes).replaceAll('=', '');
}

String _normalizeEmail(String email) => email.trim().toLowerCase();

void _validateEmail(String email) {
  final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  if (!re.hasMatch(email)) {
    throw SpodLiteException(
      message: 'Invalid email address.',
      code: SpodLiteErrorCode.invalidInput,
    );
  }
}

void _validatePassword(String password) {
  if (password.length < 8) {
    throw SpodLiteException(
      message: 'Password must be at least 8 characters.',
      code: SpodLiteErrorCode.invalidInput,
    );
  }
  if (password.length > 256) {
    throw SpodLiteException(
      message: 'Password is too long.',
      code: SpodLiteErrorCode.invalidInput,
    );
  }
}
