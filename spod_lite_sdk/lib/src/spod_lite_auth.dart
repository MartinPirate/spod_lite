import 'dart:async';

import 'admin_identity.dart';
import 'token_store.dart';

enum AuthEvent { signedIn, signedOut, sessionExpired }

/// Auth helper that drives a Serverpod Lite backend's admin endpoints.
///
/// The SDK is generic — it doesn't know the typed endpoint class from your
/// project's generated client. Instead, it takes the admin endpoint as a
/// [dynamic] proxy (duck-typed) and calls the methods every Serverpod Lite
/// server exposes:
///
///   - `Future<bool> hasAdmins()`
///   - `Future<String> signIn(email, password)`
///   - `Future<String> createFirstAdmin(email, password)`
///   - `Future<AdminUser?> me(token)`
///   - `Future<void> signOut(token)`
///
/// Any generated Serverpod client that was generated from a Serverpod Lite
/// backend will have these — that's the contract.
class SpodLiteAuth {
  final dynamic _adminEndpoint;
  final SpodLiteTokenStore _store;

  SpodLiteAuth(this._adminEndpoint, this._store);

  AdminIdentity? _currentUser;
  final _events = StreamController<AuthEvent>.broadcast();

  AdminIdentity? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  Stream<AuthEvent> get events => _events.stream;

  /// Called at startup — checks if a persisted token is still valid.
  /// Returns the current admin or null.
  Future<AdminIdentity?> restore() async {
    final token = await _store.get();
    if (token == null || token.isEmpty) return null;
    try {
      final me = await _fetchMe(token);
      if (me == null) {
        await _store.remove();
        return null;
      }
      _currentUser = me;
      _events.add(AuthEvent.signedIn);
      return me;
    } catch (_) {
      return null;
    }
  }

  /// Whether the backend has any admins yet. Use this in first-run flows.
  Future<bool> hasAdmins() async {
    return await _adminEndpoint.hasAdmins() as bool;
  }

  Future<AdminIdentity> signInAsAdmin(
      String email, String password) async {
    try {
      final token = await _adminEndpoint.signIn(email, password) as String;
      await _store.put(token);
      final me = await _fetchMe(token);
      if (me == null) {
        throw SpodLiteAuthException(
            'Sign-in succeeded but the session is invalid.');
      }
      _currentUser = me;
      _events.add(AuthEvent.signedIn);
      return me;
    } catch (e) {
      if (e is SpodLiteAuthException) rethrow;
      throw SpodLiteAuthException(_clean(e));
    }
  }

  Future<AdminIdentity> createFirstAdmin(
      String email, String password) async {
    try {
      final token =
          await _adminEndpoint.createFirstAdmin(email, password) as String;
      await _store.put(token);
      final me = await _fetchMe(token);
      if (me == null) {
        throw SpodLiteAuthException(
            'Account created but the session is invalid.');
      }
      _currentUser = me;
      _events.add(AuthEvent.signedIn);
      return me;
    } catch (e) {
      if (e is SpodLiteAuthException) rethrow;
      throw SpodLiteAuthException(_clean(e));
    }
  }

  Future<void> signOut() async {
    final token = await _store.get();
    if (token != null) {
      try {
        await _adminEndpoint.signOut(token);
      } catch (_) {
        // Non-fatal. Token is cleared locally regardless.
      }
    }
    await _store.remove();
    _currentUser = null;
    _events.add(AuthEvent.signedOut);
  }

  /// Clear the local session without calling the server. Call after an API
  /// request fails with an auth error so the UI can drop back to sign-in.
  Future<void> invalidate() async {
    await _store.remove();
    _currentUser = null;
    _events.add(AuthEvent.sessionExpired);
  }

  void dispose() {
    _events.close();
  }

  Future<AdminIdentity?> _fetchMe(String token) async {
    final raw = await _adminEndpoint.me(token);
    if (raw == null) return null;
    return AdminIdentity(
      id: raw.id as int,
      email: raw.email as String,
      createdAt: raw.createdAt as DateTime?,
    );
  }

  String _clean(Object e) {
    final s = e.toString();
    final m =
        RegExp(r'ServerpodClientException[^:]*:\s*(.+)').firstMatch(s);
    return (m?.group(1) ?? s).trim();
  }
}

class SpodLiteAuthException implements Exception {
  final String message;
  SpodLiteAuthException(this.message);
  @override
  String toString() => message;
}
