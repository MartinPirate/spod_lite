import 'package:serverpod/serverpod.dart';

import '../admin/admin_authentication_handler.dart';
import '../generated/protocol.dart';
import 'oauth_registry.dart';

/// Admin-only config for OAuth providers. The dashboard uses this to
/// set `client_id` / `client_secret` on each provider and toggle it on
/// or off without redeploying.
///
/// `clientSecret` is never returned over the wire — callers read a
/// flag-y empty string and write a new secret when they need to
/// rotate it. Writing an empty secret leaves the stored value
/// unchanged (so the dashboard can re-save other fields without
/// knowing the current secret).
class OAuthConfigEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {adminScope};

  /// All configs, secrets redacted. Unconfigured providers (registered
  /// in [OAuthRegistry] but missing from the table) are *not* returned
  /// — the dashboard lists them by walking `availableProviders`.
  Future<List<OAuthProviderConfig>> list(Session session) async {
    final rows = await OAuthProviderConfig.db.find(
      session,
      orderBy: (c) => c.provider,
    );
    return rows.map(_redact).toList();
  }

  /// Every provider the server *knows how to speak*, regardless of
  /// whether it's configured. Dashboard uses this + `list` to show
  /// "add provider" tiles for anything not yet set up.
  Future<List<String>> availableProviders(Session session) async {
    return OAuthRegistry.all().map((p) => p.id).toList();
  }

  /// Upsert a provider row.
  ///
  /// - [clientSecret] empty → keep the stored secret (rotation-safe)
  /// - [clientSecret] non-empty → replace the stored secret
  /// - The row is created if it doesn't exist yet.
  Future<OAuthProviderConfig> save(
    Session session,
    String provider,
    String clientId,
    String clientSecret,
    bool enabled,
  ) async {
    final normalized = provider.trim().toLowerCase();
    if (OAuthRegistry.lookup(normalized) == null) {
      throw SpodLiteException(
        message: 'Unknown OAuth provider "$provider".',
        code: SpodLiteErrorCode.invalidInput,
      );
    }
    if (clientId.trim().isEmpty) {
      throw SpodLiteException(
        message: 'Client ID is required.',
        code: SpodLiteErrorCode.invalidInput,
      );
    }

    final existing = await OAuthProviderConfig.db.findFirstRow(
      session,
      where: (c) => c.provider.equals(normalized),
    );
    final nowUtc = DateTime.now().toUtc();

    if (existing == null) {
      if (clientSecret.isEmpty) {
        throw SpodLiteException(
          message:
              'Client secret is required when creating a provider config.',
          code: SpodLiteErrorCode.invalidInput,
        );
      }
      final inserted = await OAuthProviderConfig.db.insertRow(
        session,
        OAuthProviderConfig(
          provider: normalized,
          clientId: clientId.trim(),
          clientSecret: clientSecret,
          enabled: enabled,
        ),
      );
      return _redact(inserted);
    }

    final updated = await OAuthProviderConfig.db.updateRow(
      session,
      existing.copyWith(
        clientId: clientId.trim(),
        clientSecret:
            clientSecret.isEmpty ? existing.clientSecret : clientSecret,
        enabled: enabled,
        updatedAt: nowUtc,
      ),
    );
    return _redact(updated);
  }

  /// Deletes the row for [provider]. Does nothing if no row exists —
  /// idempotent.
  Future<void> delete(Session session, String provider) async {
    final normalized = provider.trim().toLowerCase();
    await OAuthProviderConfig.db.deleteWhere(
      session,
      where: (c) => c.provider.equals(normalized),
    );
  }

  /// Strips the stored client secret before echoing a row to the
  /// dashboard. An empty string on a returned row means "no secret
  /// stored"; any non-empty value means "a secret is stored but we're
  /// not going to tell you what it is". On save, the dashboard sends
  /// an empty secret to keep the existing one and a non-empty one to
  /// replace it — see [save].
  OAuthProviderConfig _redact(OAuthProviderConfig c) {
    final hasSecret = c.clientSecret != null && c.clientSecret!.isNotEmpty;
    return OAuthProviderConfig(
      id: c.id,
      provider: c.provider,
      clientId: c.clientId,
      clientSecret: hasSecret ? '••••••••' : '',
      enabled: c.enabled,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
    );
  }
}
