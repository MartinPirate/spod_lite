import 'dart:async';

import 'token_store.dart';
import 'user_identity.dart';

enum UserAuthEvent { signedIn, signedOut, sessionExpired }

/// End-user auth for apps. Mirrors the admin auth flow (sign in, restore,
/// sign out, events) but against the `app_user` identity.
///
/// One app can use both: admins manage the dashboard, while app users —
/// customers, readers, whatever — sign up through the app itself. The
/// two flows are deliberately separated (separate tokens, separate
/// stores, separate scopes).
class SpodLiteUserAuth {
  final dynamic _userAuthEndpoint;
  final SpodLiteTokenStore _store;

  SpodLiteUserAuth(this._userAuthEndpoint, this._store);

  UserIdentity? _currentUser;
  final _events = StreamController<UserAuthEvent>.broadcast();

  UserIdentity? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  Stream<UserAuthEvent> get events => _events.stream;

  Future<UserIdentity?> restore() async {
    final token = await _store.get();
    if (token == null || token.isEmpty) return null;
    try {
      final me = await _fetchMe(token);
      if (me == null) {
        await _store.remove();
        return null;
      }
      _currentUser = me;
      _events.add(UserAuthEvent.signedIn);
      return me;
    } catch (_) {
      return null;
    }
  }

  Future<UserIdentity> signUp(String email, String password) async {
    try {
      final token = await _userAuthEndpoint.signUp(email, password) as String;
      await _store.put(token);
      final me = await _fetchMe(token);
      if (me == null) {
        throw SpodLiteUserAuthException(
            'Sign-up succeeded but the session is invalid.');
      }
      _currentUser = me;
      _events.add(UserAuthEvent.signedIn);
      return me;
    } catch (e) {
      if (e is SpodLiteUserAuthException) rethrow;
      throw SpodLiteUserAuthException(_clean(e));
    }
  }

  Future<UserIdentity> signIn(String email, String password) async {
    try {
      final token = await _userAuthEndpoint.signIn(email, password) as String;
      await _store.put(token);
      final me = await _fetchMe(token);
      if (me == null) {
        throw SpodLiteUserAuthException(
            'Sign-in succeeded but the session is invalid.');
      }
      _currentUser = me;
      _events.add(UserAuthEvent.signedIn);
      return me;
    } catch (e) {
      if (e is SpodLiteUserAuthException) rethrow;
      throw SpodLiteUserAuthException(_clean(e));
    }
  }

  Future<void> signOut() async {
    final token = await _store.get();
    if (token != null) {
      try {
        await _userAuthEndpoint.signOut(token);
      } catch (_) {}
    }
    await _store.remove();
    _currentUser = null;
    _events.add(UserAuthEvent.signedOut);
  }

  Future<void> invalidate() async {
    await _store.remove();
    _currentUser = null;
    _events.add(UserAuthEvent.sessionExpired);
  }

  /// Ask the server to email a verification code to the currently
  /// signed-in user. Safe to call repeatedly; no-op if already verified.
  Future<void> requestEmailVerification() async {
    final token = await _store.get();
    if (token == null) {
      throw SpodLiteUserAuthException('Sign-in required.');
    }
    try {
      await _userAuthEndpoint.requestEmailVerification(token);
    } catch (e) {
      if (e is SpodLiteUserAuthException) rethrow;
      throw SpodLiteUserAuthException(_clean(e));
    }
  }

  /// Submit the 6-digit code the user received by email. Flips the
  /// `emailVerified` flag on success.
  Future<void> verifyEmail(String code) async {
    final token = await _store.get();
    if (token == null) {
      throw SpodLiteUserAuthException('Sign-in required.');
    }
    try {
      await _userAuthEndpoint.verifyEmail(token, code);
    } catch (e) {
      if (e is SpodLiteUserAuthException) rethrow;
      throw SpodLiteUserAuthException(_clean(e));
    }
  }

  /// Send a reset code to [email]. Returns silently whether or not the
  /// account exists (no user enumeration).
  Future<void> requestPasswordReset(String email) async {
    try {
      await _userAuthEndpoint.requestPasswordReset(email);
    } catch (e) {
      if (e is SpodLiteUserAuthException) rethrow;
      throw SpodLiteUserAuthException(_clean(e));
    }
  }

  /// Confirm the reset code and set a new password. Invalidates every
  /// existing session on the account, so the caller must sign in again.
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _userAuthEndpoint.confirmPasswordReset(email, code, newPassword);
    } catch (e) {
      if (e is SpodLiteUserAuthException) rethrow;
      throw SpodLiteUserAuthException(_clean(e));
    }
  }

  void dispose() {
    _events.close();
  }

  Future<UserIdentity?> _fetchMe(String token) async {
    final raw = await _userAuthEndpoint.me(token);
    if (raw == null) return null;
    return UserIdentity(
      id: raw.id as int,
      email: raw.email as String,
      createdAt: raw.createdAt as DateTime?,
    );
  }

  String _clean(Object e) {
    try {
      final m = (e as dynamic).message;
      if (m is String && m.isNotEmpty) return m;
    } catch (_) {}
    final s = e.toString();
    final m =
        RegExp(r'ServerpodClientException[^:]*:\s*(.+)').firstMatch(s);
    return (m?.group(1) ?? s).trim();
  }
}

class SpodLiteUserAuthException implements Exception {
  final String message;
  SpodLiteUserAuthException(this.message);
  @override
  String toString() => message;
}
