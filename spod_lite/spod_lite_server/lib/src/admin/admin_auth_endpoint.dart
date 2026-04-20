import 'dart:convert';
import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'rate_limiter.dart';

const _sessionTtl = Duration(days: 30);

class AdminAuthEndpoint extends Endpoint {
  Future<bool> hasAdmins(Session session) async {
    final count = await AdminUser.db.count(session);
    return count > 0;
  }

  Future<String> createFirstAdmin(
    Session session,
    String email,
    String password,
  ) async {
    final normalized = _normalizeEmail(email);
    _validateEmail(normalized);
    _validatePassword(password);

    final existing = await AdminUser.db.count(session);
    if (existing > 0) {
      throw SpodLiteException(
        message: 'An admin already exists. Use signIn instead.',
        code: SpodLiteErrorCode.conflict,
      );
    }

    final hash = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));
    final admin = await AdminUser.db.insertRow(
      session,
      AdminUser(email: normalized, passwordHash: hash),
    );
    return _issueSession(session, admin.id!);
  }

  Future<String> signIn(
    Session session,
    String email,
    String password,
  ) async {
    final normalized = _normalizeEmail(email);
    SignInRateLimiter.check(normalized);

    final admin = await AdminUser.db.findFirstRow(
      session,
      where: (u) => u.email.equals(normalized),
    );
    if (admin == null || !BCrypt.checkpw(password, admin.passwordHash)) {
      SignInRateLimiter.recordFailure(normalized);
      session.log('[AdminAuth] Failed sign-in attempt for $normalized',
          level: LogLevel.warning);
      throw SpodLiteException(
        message: 'Invalid email or password.',
        code: SpodLiteErrorCode.unauthorized,
      );
    }
    SignInRateLimiter.recordSuccess(normalized);
    return _issueSession(session, admin.id!);
  }

  Future<AdminUser?> me(Session session, String token) async {
    final admin = await _resolveAdmin(session, token);
    if (admin == null) return null;
    return admin.copyWith(passwordHash: '');
  }

  Future<void> signOut(Session session, String token) async {
    await AdminSession.db
        .deleteWhere(session, where: (s) => s.token.equals(token));
  }

  Future<String> _issueSession(Session session, int adminUserId) async {
    final token = _randomToken();
    await AdminSession.db.insertRow(
      session,
      AdminSession(
        token: token,
        adminUserId: adminUserId,
        expiresAt: DateTime.now().toUtc().add(_sessionTtl),
      ),
    );
    return token;
  }

  Future<AdminUser?> _resolveAdmin(Session session, String token) async {
    if (token.isEmpty) return null;
    final adminSession = await AdminSession.db.findFirstRow(
      session,
      where: (s) => s.token.equals(token),
    );
    if (adminSession == null) return null;
    if (adminSession.expiresAt.isBefore(DateTime.now().toUtc())) {
      await AdminSession.db
          .deleteWhere(session, where: (s) => s.token.equals(token));
      return null;
    }
    return AdminUser.db.findById(session, adminSession.adminUserId);
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
