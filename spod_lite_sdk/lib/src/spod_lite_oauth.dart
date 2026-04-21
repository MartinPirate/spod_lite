import 'dart:async';

import 'spod_lite_user_auth.dart';
import 'token_store.dart';
import 'user_identity.dart';

/// SDK-side wrapper around the public OAuth flow. Three calls and
/// you're signed in:
///
/// ```dart
/// // Which providers does the server have configured?
/// final providers = await spod.oauth.listProviders();
///
/// // Step 1: open this URL in a system browser or webview.
/// final url = await spod.oauth.getAuthUrl(
///   provider: 'google',
///   redirectUri: 'https://myapp.example.com/oauth/callback',
/// );
///
/// // Step 2: your redirect handler parses the `state` + `code` from
/// // the query string and hands them back here.
/// final identity = await spod.oauth.completeAuth(
///   provider: 'google',
///   state: state,
///   code: code,
/// );
/// ```
///
/// `completeAuth` stores the resulting session token in the same
/// `SpodLiteTokenStore` the email-password flow uses — after it
/// returns, `spod.userAuth.isSignedIn` is true and the token goes out
/// on every authenticated call.
class SpodLiteOAuth {
  final dynamic _oauthEndpoint;
  final dynamic _userAuthEndpoint;
  final SpodLiteTokenStore _store;
  final SpodLiteUserAuth _userAuth;

  SpodLiteOAuth(
    this._oauthEndpoint,
    this._userAuthEndpoint,
    this._store,
    this._userAuth,
  );

  /// Ids of OAuth providers that are both implemented server-side and
  /// currently configured (client id + enabled). Use this to decide
  /// which sign-in buttons to render.
  Future<List<String>> listProviders() async {
    try {
      final raw = await _oauthEndpoint.listProviders() as List;
      return raw.cast<String>();
    } catch (e) {
      throw SpodLiteOAuthException(_clean(e));
    }
  }

  /// Returns the URL the user should open to consent. [redirectUri]
  /// must match one of the redirect URIs registered with the provider
  /// (Google console, GitHub app settings, etc).
  Future<String> getAuthUrl({
    required String provider,
    required String redirectUri,
  }) async {
    try {
      return await _oauthEndpoint.getAuthUrl(provider, redirectUri) as String;
    } catch (e) {
      throw SpodLiteOAuthException(_clean(e));
    }
  }

  /// Finish a flow. Pass the `state` and `code` you got on the
  /// redirect. On success the app-user session is created and
  /// persisted; the returned [UserIdentity] is also available at
  /// `spod.userAuth.currentUser`.
  Future<UserIdentity> completeAuth({
    required String provider,
    required String state,
    required String code,
  }) async {
    try {
      final token = await _oauthEndpoint.completeAuth(provider, state, code)
          as String;
      await _store.put(token);
      final me = await _fetchMe(token);
      if (me == null) {
        throw SpodLiteOAuthException(
          'OAuth succeeded but the returned session is invalid.',
        );
      }
      _userAuth.adoptOAuthSession(me);
      return me;
    } catch (e) {
      if (e is SpodLiteOAuthException) rethrow;
      throw SpodLiteOAuthException(_clean(e));
    }
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

class SpodLiteOAuthException implements Exception {
  final String message;
  SpodLiteOAuthException(this.message);
  @override
  String toString() => message;
}
