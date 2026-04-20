import 'package:flutter/foundation.dart';
import 'package:spod_lite_client/spod_lite_client.dart';

import 'admin_auth_key_provider.dart';

enum AuthStatus { loading, bootstrap, signedOut, signedIn, serverDown }

class AuthState extends ChangeNotifier {
  final Client _client;
  final AdminAuthKeyProvider _keys;

  AuthState(this._client, this._keys);

  AuthStatus _status = AuthStatus.loading;
  AdminUser? _admin;
  String? _error;

  AuthStatus get status => _status;
  AdminUser? get admin => _admin;
  String? get error => _error;

  Future<void> bootstrap() async {
    _setStatus(AuthStatus.loading);
    _error = null;
    try {
      final cached = await _keys.get();
      if (cached != null && cached.isNotEmpty) {
        final me = await _client.adminAuth.me(cached);
        if (me != null) {
          _admin = me;
          _setStatus(AuthStatus.signedIn);
          return;
        }
        await _keys.remove();
      }

      final hasAdmins = await _client.adminAuth.hasAdmins();
      _setStatus(hasAdmins ? AuthStatus.signedOut : AuthStatus.bootstrap);
    } catch (e, st) {
      debugPrint('AuthState.bootstrap error: $e\n$st');
      _error = 'Cannot reach the Serverpod Lite API. '
          'Check that the server is running on :8088.';
      _setStatus(AuthStatus.serverDown);
    }
  }

  Future<bool> createFirstAdmin(String email, String password) async {
    _error = null;
    try {
      final token = await _client.adminAuth.createFirstAdmin(email, password);
      await _keys.put(token);
      _admin = await _client.adminAuth.me(token);
      _setStatus(AuthStatus.signedIn);
      return true;
    } catch (e) {
      _error = _cleanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _error = null;
    try {
      final token = await _client.adminAuth.signIn(email, password);
      await _keys.put(token);
      _admin = await _client.adminAuth.me(token);
      _setStatus(AuthStatus.signedIn);
      return true;
    } catch (e) {
      _error = _cleanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    final token = await _keys.get();
    if (token != null) {
      try {
        await _client.adminAuth.signOut(token);
      } catch (_) {}
    }
    await _keys.remove();
    _admin = null;
    _error = null;
    try {
      final hasAdmins = await _client.adminAuth.hasAdmins();
      _setStatus(hasAdmins ? AuthStatus.signedOut : AuthStatus.bootstrap);
    } catch (_) {
      _setStatus(AuthStatus.signedOut);
    }
  }

  /// Call when an API request fails with an auth error so the UI drops back
  /// to the sign-in screen cleanly.
  Future<void> invalidate() async {
    await _keys.remove();
    _admin = null;
    _setStatus(AuthStatus.signedOut);
  }

  void _setStatus(AuthStatus s) {
    _status = s;
    notifyListeners();
  }

  String _cleanError(Object e) {
    final s = e.toString();
    final match =
        RegExp(r'ServerpodClientException[^:]*:\s*(.+)').firstMatch(s);
    return (match?.group(1) ?? s).trim();
  }
}
