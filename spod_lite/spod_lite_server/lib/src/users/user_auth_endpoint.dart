import 'dart:convert';
import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'user_rate_limiter.dart';

const _sessionTtl = Duration(days: 30);

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
      throw _AuthException('An account with that email already exists.');
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
      throw _AuthException('Invalid email or password.');
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
    throw _AuthException('Invalid email address.');
  }
}

void _validatePassword(String password) {
  if (password.length < 8) {
    throw _AuthException('Password must be at least 8 characters.');
  }
  if (password.length > 256) {
    throw _AuthException('Password is too long.');
  }
}

class _AuthException implements Exception {
  final String message;
  _AuthException(this.message);
  @override
  String toString() => message;
}
