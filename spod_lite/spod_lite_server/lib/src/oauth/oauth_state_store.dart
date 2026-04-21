import 'dart:convert';
import 'dart:math';

/// Short-lived OAuth state entry. Produced when we hand the caller an
/// auth URL; consumed (and deleted) when the caller returns with a code.
class OAuthStateEntry {
  final String provider;
  final String redirectUri;
  final DateTime expiresAt;
  const OAuthStateEntry({
    required this.provider,
    required this.redirectUri,
    required this.expiresAt,
  });
}

/// Process-wide store of OAuth `state` nonces.
///
/// We use this to (a) prove the callback came from a flow we started
/// (CSRF defence), and (b) recover the `redirect_uri` used in step 1 so
/// we can supply the same value in the token exchange — Google requires
/// them to match byte-for-byte.
///
/// In-memory keeps the implementation simple and zero-deps; it's fine
/// for single-instance deploys. For a cluster, swap [OAuthStateStore]
/// for a Redis-backed impl behind the same API — no callers change.
class OAuthStateStore {
  OAuthStateStore._();

  static final Map<String, OAuthStateEntry> _store = {};
  static final _rand = Random.secure();

  static const _ttl = Duration(minutes: 10);

  /// Produce a new state token, store the flow metadata against it, and
  /// return the token to the caller. The token is 32 cryptographically
  /// random bytes, URL-safe base64.
  static String issue({
    required String provider,
    required String redirectUri,
  }) {
    _sweep();
    final bytes = List<int>.generate(32, (_) => _rand.nextInt(256));
    final token = base64UrlEncode(bytes).replaceAll('=', '');
    _store[token] = OAuthStateEntry(
      provider: provider,
      redirectUri: redirectUri,
      expiresAt: DateTime.now().toUtc().add(_ttl),
    );
    return token;
  }

  /// Look up [token] and remove it from the store (single-use). Returns
  /// null if the token is unknown or expired.
  static OAuthStateEntry? consume(String token) {
    _sweep();
    final entry = _store.remove(token);
    if (entry == null) return null;
    if (entry.expiresAt.isBefore(DateTime.now().toUtc())) return null;
    return entry;
  }

  /// Drop every expired entry. Called lazily on issue/consume; avoids a
  /// background timer so the store costs nothing when idle.
  static void _sweep() {
    final now = DateTime.now().toUtc();
    _store.removeWhere((_, e) => e.expiresAt.isBefore(now));
  }
}
