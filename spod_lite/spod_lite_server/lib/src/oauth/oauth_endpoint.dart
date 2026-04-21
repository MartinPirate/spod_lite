import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../users/session_mint.dart';
import 'oauth_registry.dart';
import 'oauth_state_store.dart';
import 'providers/oauth_provider.dart';

/// Public OAuth flow. Three endpoints, zero admin scope:
///
/// 1. `listProviders` — which providers are enabled on this server.
/// 2. `getAuthUrl` — start a flow; returns the consent URL the browser
///    opens and stores a single-use state nonce server-side.
/// 3. `completeAuth` — finish a flow; exchanges the code, finds-or-
///    creates the `AppUser`, and returns an `AppSession` token.
class OAuthEndpoint extends Endpoint {
  /// Ids of providers that are both registered in [OAuthRegistry] *and*
  /// have an enabled row in `oauth_provider_config`. The dashboard/app
  /// uses this to decide which sign-in buttons to render.
  Future<List<String>> listProviders(Session session) async {
    final configs = await OAuthProviderConfig.db.find(
      session,
      where: (c) => c.enabled.equals(true),
    );
    final out = <String>[];
    for (final c in configs) {
      if (OAuthRegistry.lookup(c.provider) == null) continue;
      if (c.clientId.isEmpty) continue;
      out.add(c.provider);
    }
    return out;
  }

  /// Returns the URL to open in a browser to start the OAuth flow.
  /// The caller must pass the same [redirectUri] it registered with
  /// the provider — we round-trip it through state so the token
  /// exchange supplies the same value Google signed against.
  Future<String> getAuthUrl(
    Session session,
    String provider,
    String redirectUri,
  ) async {
    final impl = _requireProvider(provider);
    final config = await _requireConfig(session, provider);

    final state = OAuthStateStore.issue(
      provider: provider,
      redirectUri: redirectUri,
    );
    final url = impl.buildAuthUrl(
      clientId: config.clientId,
      redirectUri: redirectUri,
      state: state,
    );
    return url.toString();
  }

  /// Completes an OAuth flow. Consumes the state, exchanges the code,
  /// resolves identity, then either links to an existing user (by
  /// verified email) or provisions a new one. Returns an app-session
  /// token the SDK can use immediately.
  Future<String> completeAuth(
    Session session,
    String provider,
    String state,
    String code,
  ) async {
    final flow = OAuthStateStore.consume(state);
    if (flow == null) {
      throw SpodLiteException(
        message: 'OAuth flow expired or was never started. Try again.',
        code: SpodLiteErrorCode.invalidInput,
      );
    }
    if (flow.provider != provider) {
      throw SpodLiteException(
        message: 'OAuth state mismatch.',
        code: SpodLiteErrorCode.invalidInput,
      );
    }

    final impl = _requireProvider(provider);
    final config = await _requireConfig(session, provider);

    final OAuthIdentity identity;
    try {
      identity = await impl.resolveIdentity(
        session: session,
        config: config,
        code: code,
        redirectUri: flow.redirectUri,
      );
    } on OAuthUpstreamException catch (e) {
      throw SpodLiteException(
        message: e.message,
        code: SpodLiteErrorCode.unauthorized,
      );
    }

    final email = identity.email;
    if (email == null || email.isEmpty) {
      throw SpodLiteException(
        message: 'Provider did not return an email address.',
        code: SpodLiteErrorCode.unauthorized,
      );
    }
    if (!identity.emailVerified) {
      // We gate account linking on a verified email — otherwise anyone
      // who signs up with the same address at Google first can hijack
      // the email-password account, and vice versa.
      throw SpodLiteException(
        message: 'Provider reports this email is not verified.',
        code: SpodLiteErrorCode.unauthorized,
      );
    }
    final normalized = email.trim().toLowerCase();

    final user = await session.db.transaction<AppUser>((tx) async {
      // 1. Already linked? Use it.
      final existingLink = await UserOAuthLink.db.findFirstRow(
        session,
        where: (l) =>
            l.provider.equals(provider) &
            l.providerUserId.equals(identity.providerUserId),
        transaction: tx,
      );
      if (existingLink != null) {
        final u = await AppUser.db.findById(
          session,
          existingLink.appUserId,
          transaction: tx,
        );
        if (u != null) return u;
        // Orphan link — user was deleted out from under it. Remove and
        // fall through to create a new account.
        await UserOAuthLink.db.deleteRow(session, existingLink, transaction: tx);
      }

      // 2. AppUser by email? Link and reuse.
      final byEmail = await AppUser.db.findFirstRow(
        session,
        where: (u) => u.email.equals(normalized),
        transaction: tx,
      );
      if (byEmail != null) {
        await UserOAuthLink.db.insertRow(
          session,
          UserOAuthLink(
            appUserId: byEmail.id!,
            provider: provider,
            providerUserId: identity.providerUserId,
            emailAtLink: normalized,
          ),
          transaction: tx,
        );
        // Promote to verified — the provider just asserted it.
        if (!byEmail.emailVerified) {
          return AppUser.db.updateRow(
            session,
            byEmail.copyWith(emailVerified: true),
            transaction: tx,
          );
        }
        return byEmail;
      }

      // 3. New account. Password is sentinel — the email-password
      // sign-in path detects it and rejects. Users who want a password
      // on an OAuth account can add one via `confirmPasswordReset`.
      final created = await AppUser.db.insertRow(
        session,
        AppUser(
          email: normalized,
          passwordHash: '!oauth',
          emailVerified: true,
        ),
        transaction: tx,
      );
      await UserOAuthLink.db.insertRow(
        session,
        UserOAuthLink(
          appUserId: created.id!,
          provider: provider,
          providerUserId: identity.providerUserId,
          emailAtLink: normalized,
        ),
        transaction: tx,
      );
      return created;
    });

    return mintAppSession(session, user.id!);
  }

  OAuthProvider _requireProvider(String id) {
    final impl = OAuthRegistry.lookup(id);
    if (impl == null) {
      throw SpodLiteException(
        message: 'Unknown OAuth provider "$id".',
        code: SpodLiteErrorCode.invalidInput,
      );
    }
    return impl;
  }

  Future<OAuthProviderConfig> _requireConfig(
      Session session, String id) async {
    final config = await OAuthProviderConfig.db.findFirstRow(
      session,
      where: (c) => c.provider.equals(id) & c.enabled.equals(true),
    );
    if (config == null || config.clientId.isEmpty) {
      throw SpodLiteException(
        message:
            'OAuth provider "$id" is not configured. Set client id and secret in the admin dashboard first.',
        code: SpodLiteErrorCode.invalidInput,
      );
    }
    return config;
  }

}
