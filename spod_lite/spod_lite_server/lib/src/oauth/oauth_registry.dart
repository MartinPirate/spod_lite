import 'providers/google_provider.dart';
import 'providers/oauth_provider.dart';

/// Process-wide registry of OAuth provider implementations. Keyed by
/// [OAuthProvider.id]. Register providers here at startup; the endpoint
/// resolves them by id on each request.
class OAuthRegistry {
  static final Map<String, OAuthProvider> _providers = {
    for (final p in <OAuthProvider>[
      GoogleOAuthProvider(),
      // Add GitHub / Apple / etc here as they land.
    ])
      p.id: p,
  };

  /// Returns the provider for [id], or `null` if no implementation is
  /// registered. Used by the endpoint to reject unknown providers early.
  static OAuthProvider? lookup(String id) => _providers[id.toLowerCase()];

  /// All registered providers. Dashboard uses this to show which ids
  /// can be configured; endpoint uses it for `listProviders`.
  static List<OAuthProvider> all() => _providers.values.toList();
}
