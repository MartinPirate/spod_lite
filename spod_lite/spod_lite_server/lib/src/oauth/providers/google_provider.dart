import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'oauth_provider.dart';

/// Sign in with Google via OpenID Connect.
///
/// - Auth URL: `https://accounts.google.com/o/oauth2/v2/auth`
/// - Token:    `https://oauth2.googleapis.com/token`
/// - Userinfo: `https://openidconnect.googleapis.com/v1/userinfo`
///
/// We request the `openid email profile` scopes — enough to identify
/// the account by email without pulling extra profile data we don't
/// use. No offline access / refresh token; a session lasts until its
/// `AppSession.expiresAt` and the user re-authenticates cleanly.
class GoogleOAuthProvider extends OAuthProvider {
  @override
  String get id => 'google';

  @override
  String get label => 'Google';

  static const _authEndpoint = 'https://accounts.google.com/o/oauth2/v2/auth';
  static const _tokenEndpoint = 'https://oauth2.googleapis.com/token';
  static const _userinfoEndpoint =
      'https://openidconnect.googleapis.com/v1/userinfo';

  @override
  Uri buildAuthUrl({
    required String clientId,
    required String redirectUri,
    required String state,
  }) {
    return Uri.parse(_authEndpoint).replace(queryParameters: {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': 'openid email profile',
      'state': state,
      'access_type': 'online',
      'prompt': 'select_account',
    });
  }

  @override
  Future<OAuthIdentity> resolveIdentity({
    required Session session,
    required OAuthProviderConfig config,
    required String code,
    required String redirectUri,
  }) async {
    final secret = config.clientSecret;
    if (secret == null || secret.isEmpty) {
      throw OAuthUpstreamException(
        'Google OAuth is not configured with a client secret.',
      );
    }

    final tokenRes = await http.post(
      Uri.parse(_tokenEndpoint),
      headers: {'Accept': 'application/json'},
      body: {
        'client_id': config.clientId,
        'client_secret': secret,
        'code': code,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
      },
    );
    if (tokenRes.statusCode != 200) {
      session.log(
        '[oauth:google] token exchange failed: ${tokenRes.statusCode} '
        '${tokenRes.body}',
        level: LogLevel.warning,
      );
      throw OAuthUpstreamException(
        'Google rejected the authorization code.',
      );
    }

    final tokenBody = jsonDecode(tokenRes.body) as Map<String, dynamic>;
    final accessToken = tokenBody['access_token'] as String?;
    if (accessToken == null) {
      throw OAuthUpstreamException(
        'Google did not return an access token.',
      );
    }

    final userRes = await http.get(
      Uri.parse(_userinfoEndpoint),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (userRes.statusCode != 200) {
      session.log(
        '[oauth:google] userinfo failed: ${userRes.statusCode} ${userRes.body}',
        level: LogLevel.warning,
      );
      throw OAuthUpstreamException(
        'Could not fetch Google profile.',
      );
    }

    final userBody = jsonDecode(userRes.body) as Map<String, dynamic>;
    final sub = userBody['sub'] as String?;
    if (sub == null) {
      throw OAuthUpstreamException(
        'Google profile is missing a user id.',
      );
    }
    return OAuthIdentity(
      providerUserId: sub,
      email: userBody['email'] as String?,
      emailVerified: userBody['email_verified'] == true,
    );
  }
}
