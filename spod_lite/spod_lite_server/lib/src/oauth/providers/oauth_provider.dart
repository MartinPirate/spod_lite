import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

/// The identity a provider hands back after a successful code exchange.
/// Just what we need to find-or-create an `AppUser` — no profile, no
/// avatar, no refresh tokens (we don't store them yet).
class OAuthIdentity {
  /// The provider's stable ID for this user. For OIDC providers this is
  /// the `sub` claim; for OAuth2 providers it's the API's user id.
  final String providerUserId;

  /// The email the provider returned for this user. May be missing on
  /// some providers (GitHub without verified email) — we reject those
  /// at the endpoint layer since we identify accounts by email.
  final String? email;

  /// Whether the provider asserts the email has been verified. For
  /// first-party account linking we only trust verified emails.
  final bool emailVerified;

  const OAuthIdentity({
    required this.providerUserId,
    required this.email,
    required this.emailVerified,
  });
}

/// A pluggable OAuth provider. Implementations build the authorization
/// URL, exchange the authorization code for tokens, and turn those
/// tokens into an [OAuthIdentity]. Everything stateful lives outside —
/// providers are request-scoped and safe to instantiate per call.
abstract class OAuthProvider {
  /// Stable id; matches the `provider` column on [OAuthProviderConfig]
  /// and `UserOAuthLink`. Lowercase, URL-safe.
  String get id;

  /// Human label for the dashboard and error messages.
  String get label;

  /// Builds the URL the user's browser opens to start the flow.
  Uri buildAuthUrl({
    required String clientId,
    required String redirectUri,
    required String state,
  });

  /// Exchanges [code] for an access token and pulls enough identity
  /// information to find-or-create an [AppUser].
  Future<OAuthIdentity> resolveIdentity({
    required Session session,
    required OAuthProviderConfig config,
    required String code,
    required String redirectUri,
  });
}

/// Thrown from a provider when the upstream OAuth flow fails (code
/// exchange rejected, userinfo 401, etc). The endpoint catches and
/// re-throws as [SpodLiteException] with `unauthorized`.
class OAuthUpstreamException implements Exception {
  final String message;
  OAuthUpstreamException(this.message);
  @override
  String toString() => 'OAuthUpstreamException: $message';
}
