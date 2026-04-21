/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:spod_lite_client/src/protocol/admin/admin_user.dart' as _i3;
import 'package:spod_lite_client/src/protocol/collections/collection_def.dart'
    as _i4;
import 'package:spod_lite_client/src/protocol/collections/collection_field.dart'
    as _i5;
import 'dart:typed_data' as _i6;
import 'package:spod_lite_client/src/protocol/collections/record_event.dart'
    as _i7;
import 'package:spod_lite_client/src/protocol/greetings/greeting.dart' as _i8;
import 'package:spod_lite_client/src/protocol/oauth/oauth_provider_config.dart'
    as _i9;
import 'package:spod_lite_client/src/protocol/posts/post.dart' as _i10;
import 'package:spod_lite_client/src/protocol/users/app_user.dart' as _i11;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i12;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i13;
import 'protocol.dart' as _i14;

/// {@category Endpoint}
class EndpointAdminAuth extends _i1.EndpointRef {
  EndpointAdminAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'adminAuth';

  _i2.Future<bool> hasAdmins() => caller.callServerEndpoint<bool>(
    'adminAuth',
    'hasAdmins',
    {},
  );

  _i2.Future<String> createFirstAdmin(
    String email,
    String password,
  ) => caller.callServerEndpoint<String>(
    'adminAuth',
    'createFirstAdmin',
    {
      'email': email,
      'password': password,
    },
  );

  _i2.Future<String> signIn(
    String email,
    String password,
  ) => caller.callServerEndpoint<String>(
    'adminAuth',
    'signIn',
    {
      'email': email,
      'password': password,
    },
  );

  _i2.Future<_i3.AdminUser?> me(String token) =>
      caller.callServerEndpoint<_i3.AdminUser?>(
        'adminAuth',
        'me',
        {'token': token},
      );

  _i2.Future<void> signOut(String token) => caller.callServerEndpoint<void>(
    'adminAuth',
    'signOut',
    {'token': token},
  );
}

/// Admin-only API for managing *other* admin users.
/// {@category Endpoint}
class EndpointAdmins extends _i1.EndpointRef {
  EndpointAdmins(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'admins';

  _i2.Future<List<_i3.AdminUser>> list() =>
      caller.callServerEndpoint<List<_i3.AdminUser>>(
        'admins',
        'list',
        {},
      );

  _i2.Future<int> count() => caller.callServerEndpoint<int>(
    'admins',
    'count',
    {},
  );

  _i2.Future<_i3.AdminUser> invite(
    String email,
    String password,
  ) => caller.callServerEndpoint<_i3.AdminUser>(
    'admins',
    'invite',
    {
      'email': email,
      'password': password,
    },
  );

  _i2.Future<void> revoke(int adminId) => caller.callServerEndpoint<void>(
    'admins',
    'revoke',
    {'adminId': adminId},
  );
}

/// Dashboard-side API for creating and listing user-defined collections.
///
/// Each collection is backed by a dynamically-created `collection_<name>`
/// table in Postgres. Definitions live in `collection_def` and
/// `collection_field`. All DDL goes through [quoteIdent] after
/// [assertValidIdentifier] — there is no other path.
/// {@category Endpoint}
class EndpointCollections extends _i1.EndpointRef {
  EndpointCollections(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'collections';

  _i2.Future<List<_i4.CollectionDef>> list() =>
      caller.callServerEndpoint<List<_i4.CollectionDef>>(
        'collections',
        'list',
        {},
      );

  _i2.Future<_i4.CollectionDef?> get(String name) =>
      caller.callServerEndpoint<_i4.CollectionDef?>(
        'collections',
        'get',
        {'name': name},
      );

  _i2.Future<List<_i5.CollectionField>> fields(int collectionDefId) =>
      caller.callServerEndpoint<List<_i5.CollectionField>>(
        'collections',
        'fields',
        {'collectionDefId': collectionDefId},
      );

  /// Create a collection: inserts definition + field rows and runs
  /// `CREATE TABLE` atomically. If any step fails the whole thing
  /// rolls back so we don't orphan a definition without a table (or
  /// vice versa).
  /// `specsJson` must decode to a JSON array of `{name, fieldType, required}`
  /// objects. JSON on the wire keeps this endpoint free of generated-type
  /// dependencies so any Serverpod client can call it.
  _i2.Future<_i4.CollectionDef> create(
    String name,
    String label,
    String specsJson,
  ) => caller.callServerEndpoint<_i4.CollectionDef>(
    'collections',
    'create',
    {
      'name': name,
      'label': label,
      'specsJson': specsJson,
    },
  );

  /// Delete a collection: drops the dynamic table first (if present),
  /// then the definition — which cascades to its fields.
  _i2.Future<void> delete(String name) => caller.callServerEndpoint<void>(
    'collections',
    'delete',
    {'name': name},
  );

  /// Update the 5 per-op rules on an existing collection. Accepts any
  /// subset; omitted keys stay unchanged. Allowed values: `public`,
  /// `authed`, `admin`.
  _i2.Future<_i4.CollectionDef> updateRules(
    String name,
    String rulesJson,
  ) => caller.callServerEndpoint<_i4.CollectionDef>(
    'collections',
    'updateRules',
    {
      'name': name,
      'rulesJson': rulesJson,
    },
  );
}

/// Upload/delete files attached to records on user-defined collections.
///
/// The public URL is written into the record's column (type 'file'), and
/// served back via Serverpod's built-in `/serverpod_cloud_storage/file`
/// endpoint. Rule enforcement mirrors record writes: `createRule` for
/// uploads, `deleteRule` for removals.
/// {@category Endpoint}
class EndpointFiles extends _i1.EndpointRef {
  EndpointFiles(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'files';

  _i2.Future<String> upload(
    String collectionName,
    int recordId,
    String fieldName,
    _i6.ByteData bytes,
    String filename,
  ) => caller.callServerEndpoint<String>(
    'files',
    'upload',
    {
      'collectionName': collectionName,
      'recordId': recordId,
      'fieldName': fieldName,
      'bytes': bytes,
      'filename': filename,
    },
  );

  _i2.Future<void> delete(
    String collectionName,
    int recordId,
    String fieldName,
  ) => caller.callServerEndpoint<void>(
    'files',
    'delete',
    {
      'collectionName': collectionName,
      'recordId': recordId,
      'fieldName': fieldName,
    },
  );
}

/// Generic CRUD over user-defined collections.
///
/// Records are passed across the wire as JSON strings because Serverpod's
/// type system doesn't allow `Map<String, dynamic>` — the SDK and
/// dashboard handle the string ↔ map conversion so callers never see it.
///
/// All data values flow through positional/named query parameters —
/// never interpolated. Identifiers go through [quoteIdent] after
/// [assertValidIdentifier].
/// {@category Endpoint}
class EndpointRecords extends _i1.EndpointRef {
  EndpointRecords(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'records';

  /// Returns a list of records encoded as JSON strings.
  _i2.Future<List<String>> list(
    String collectionName,
    int page,
    int perPage,
  ) => caller.callServerEndpoint<List<String>>(
    'records',
    'list',
    {
      'collectionName': collectionName,
      'page': page,
      'perPage': perPage,
    },
  );

  _i2.Future<int> count(String collectionName) =>
      caller.callServerEndpoint<int>(
        'records',
        'count',
        {'collectionName': collectionName},
      );

  _i2.Future<String?> get(
    String collectionName,
    int id,
  ) => caller.callServerEndpoint<String?>(
    'records',
    'get',
    {
      'collectionName': collectionName,
      'id': id,
    },
  );

  _i2.Future<String> create(
    String collectionName,
    String dataJson,
  ) => caller.callServerEndpoint<String>(
    'records',
    'create',
    {
      'collectionName': collectionName,
      'dataJson': dataJson,
    },
  );

  _i2.Future<String> update(
    String collectionName,
    int id,
    String dataJson,
  ) => caller.callServerEndpoint<String>(
    'records',
    'update',
    {
      'collectionName': collectionName,
      'id': id,
      'dataJson': dataJson,
    },
  );

  _i2.Future<void> delete(
    String collectionName,
    int id,
  ) => caller.callServerEndpoint<void>(
    'records',
    'delete',
    {
      'collectionName': collectionName,
      'id': id,
    },
  );

  /// Live stream of record events for a collection. Enforces the same
  /// rule as `list`. For row-level rules, `created`/`updated` events are
  /// filtered against the current state; `deleted` events carry only an
  /// id (no row to evaluate) and are delivered unconditionally — UIs
  /// need the signal to remove stale items they may have already
  /// surfaced. This trades a small existence leak for live-sync
  /// usability; see docs/rules.md.
  _i2.Stream<_i7.RecordEvent> watch(String collectionName) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i7.RecordEvent>,
        _i7.RecordEvent
      >(
        'records',
        'watch',
        {'collectionName': collectionName},
        {},
      );
}

/// Admin-only API for the email module. For now: expose the active
/// driver name and a test-send. Password-reset / verification flows
/// will go on this surface later.
/// {@category Endpoint}
class EndpointEmails extends _i1.EndpointRef {
  EndpointEmails(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emails';

  /// Returns which driver is currently active (`console` by default,
  /// `smtp` if the server was booted with SPOD_SMTP_* env vars).
  _i2.Future<String> driverName() => caller.callServerEndpoint<String>(
    'emails',
    'driverName',
    {},
  );

  _i2.Future<void> sendTest(
    String to,
    String subject,
    String body,
  ) => caller.callServerEndpoint<void>(
    'emails',
    'sendTest',
    {
      'to': to,
      'subject': subject,
      'body': body,
    },
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i8.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i8.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// Admin-only read of Serverpod's recent session log table. Each row
/// is returned as a JSON string so the client can render arbitrary
/// columns without us inventing a transport type.
/// {@category Endpoint}
class EndpointLogs extends _i1.EndpointRef {
  EndpointLogs(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'logs';

  _i2.Future<List<String>> recent(int limit) =>
      caller.callServerEndpoint<List<String>>(
        'logs',
        'recent',
        {'limit': limit},
      );

  _i2.Future<int> count() => caller.callServerEndpoint<int>(
    'logs',
    'count',
    {},
  );
}

/// Admin-only config for OAuth providers. The dashboard uses this to
/// set `client_id` / `client_secret` on each provider and toggle it on
/// or off without redeploying.
///
/// `clientSecret` is never returned over the wire — callers read a
/// flag-y empty string and write a new secret when they need to
/// rotate it. Writing an empty secret leaves the stored value
/// unchanged (so the dashboard can re-save other fields without
/// knowing the current secret).
/// {@category Endpoint}
class EndpointOAuthConfig extends _i1.EndpointRef {
  EndpointOAuthConfig(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'oAuthConfig';

  /// All configs, secrets redacted. Unconfigured providers (registered
  /// in [OAuthRegistry] but missing from the table) are *not* returned
  /// — the dashboard lists them by walking `availableProviders`.
  _i2.Future<List<_i9.OAuthProviderConfig>> list() =>
      caller.callServerEndpoint<List<_i9.OAuthProviderConfig>>(
        'oAuthConfig',
        'list',
        {},
      );

  /// Every provider the server *knows how to speak*, regardless of
  /// whether it's configured. Dashboard uses this + `list` to show
  /// "add provider" tiles for anything not yet set up.
  _i2.Future<List<String>> availableProviders() =>
      caller.callServerEndpoint<List<String>>(
        'oAuthConfig',
        'availableProviders',
        {},
      );

  /// Upsert a provider row.
  ///
  /// - [clientSecret] empty → keep the stored secret (rotation-safe)
  /// - [clientSecret] non-empty → replace the stored secret
  /// - The row is created if it doesn't exist yet.
  _i2.Future<_i9.OAuthProviderConfig> save(
    String provider,
    String clientId,
    String clientSecret,
    bool enabled,
  ) => caller.callServerEndpoint<_i9.OAuthProviderConfig>(
    'oAuthConfig',
    'save',
    {
      'provider': provider,
      'clientId': clientId,
      'clientSecret': clientSecret,
      'enabled': enabled,
    },
  );

  /// Deletes the row for [provider]. Does nothing if no row exists —
  /// idempotent.
  _i2.Future<void> delete(String provider) => caller.callServerEndpoint<void>(
    'oAuthConfig',
    'delete',
    {'provider': provider},
  );
}

/// Public OAuth flow. Three endpoints, zero admin scope:
///
/// 1. `listProviders` — which providers are enabled on this server.
/// 2. `getAuthUrl` — start a flow; returns the consent URL the browser
///    opens and stores a single-use state nonce server-side.
/// 3. `completeAuth` — finish a flow; exchanges the code, finds-or-
///    creates the `AppUser`, and returns an `AppSession` token.
/// {@category Endpoint}
class EndpointOAuth extends _i1.EndpointRef {
  EndpointOAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'oAuth';

  /// Ids of providers that are both registered in [OAuthRegistry] *and*
  /// have an enabled row in `oauth_provider_config`. The dashboard/app
  /// uses this to decide which sign-in buttons to render.
  _i2.Future<List<String>> listProviders() =>
      caller.callServerEndpoint<List<String>>(
        'oAuth',
        'listProviders',
        {},
      );

  /// Returns the URL to open in a browser to start the OAuth flow.
  /// The caller must pass the same [redirectUri] it registered with
  /// the provider — we round-trip it through state so the token
  /// exchange supplies the same value Google signed against.
  _i2.Future<String> getAuthUrl(
    String provider,
    String redirectUri,
  ) => caller.callServerEndpoint<String>(
    'oAuth',
    'getAuthUrl',
    {
      'provider': provider,
      'redirectUri': redirectUri,
    },
  );

  /// Completes an OAuth flow. Consumes the state, exchanges the code,
  /// resolves identity, then either links to an existing user (by
  /// verified email) or provisions a new one. Returns an app-session
  /// token the SDK can use immediately.
  _i2.Future<String> completeAuth(
    String provider,
    String state,
    String code,
  ) => caller.callServerEndpoint<String>(
    'oAuth',
    'completeAuth',
    {
      'provider': provider,
      'state': state,
      'code': code,
    },
  );
}

/// Legacy demo endpoint kept around for the demo app. Gated via
/// `requireLogin` so any authenticated caller (admin or end-user) can use
/// it. New work should prefer the generic collections/records API which
/// supports per-op rules.
/// {@category Endpoint}
class EndpointPosts extends _i1.EndpointRef {
  EndpointPosts(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'posts';

  _i2.Future<List<_i10.Post>> listPosts() =>
      caller.callServerEndpoint<List<_i10.Post>>(
        'posts',
        'listPosts',
        {},
      );

  _i2.Future<_i10.Post> createPost(
    String title,
    String body,
  ) => caller.callServerEndpoint<_i10.Post>(
    'posts',
    'createPost',
    {
      'title': title,
      'body': body,
    },
  );

  _i2.Future<void> deletePost(int id) => caller.callServerEndpoint<void>(
    'posts',
    'deletePost',
    {'id': id},
  );

  /// Live feed — every new post from [createPost] is pushed to subscribers
  /// over a WebSocket. Useful primarily for the demo app.
  _i2.Stream<_i10.Post> watchPosts() =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i10.Post>, _i10.Post>(
        'posts',
        'watchPosts',
        {},
        {},
      );
}

/// Self-serve end-user auth. Public endpoint — anyone can hit `signUp`
/// and `signIn`. Signing in returns a token that the SDK attaches to
/// subsequent requests; the authentication handler resolves it into a
/// `user` scope for rule evaluation.
/// {@category Endpoint}
class EndpointUserAuth extends _i1.EndpointRef {
  EndpointUserAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'userAuth';

  _i2.Future<String> signUp(
    String email,
    String password,
  ) => caller.callServerEndpoint<String>(
    'userAuth',
    'signUp',
    {
      'email': email,
      'password': password,
    },
  );

  _i2.Future<String> signIn(
    String email,
    String password,
  ) => caller.callServerEndpoint<String>(
    'userAuth',
    'signIn',
    {
      'email': email,
      'password': password,
    },
  );

  _i2.Future<_i11.AppUser?> me(String token) =>
      caller.callServerEndpoint<_i11.AppUser?>(
        'userAuth',
        'me',
        {'token': token},
      );

  _i2.Future<void> signOut(String token) => caller.callServerEndpoint<void>(
    'userAuth',
    'signOut',
    {'token': token},
  );

  /// Generates a verification code, persists it on the caller's account,
  /// and emails it. Idempotent if the user is already verified.
  _i2.Future<void> requestEmailVerification(String token) =>
      caller.callServerEndpoint<void>(
        'userAuth',
        'requestEmailVerification',
        {'token': token},
      );

  /// Confirms an email-verification code. Marks the account verified and
  /// clears the code on success. Throws on invalid or expired codes.
  _i2.Future<void> verifyEmail(
    String token,
    String code,
  ) => caller.callServerEndpoint<void>(
    'userAuth',
    'verifyEmail',
    {
      'token': token,
      'code': code,
    },
  );

  /// Sends a password-reset code to the account at [email] if one exists.
  /// Always returns normally so the endpoint can't be used for user
  /// enumeration.
  _i2.Future<void> requestPasswordReset(String email) =>
      caller.callServerEndpoint<void>(
        'userAuth',
        'requestPasswordReset',
        {'email': email},
      );

  /// Confirms a password-reset code and sets a new password. Invalidates
  /// every existing session on the account so a stolen session can't
  /// survive a reset.
  _i2.Future<void> confirmPasswordReset(
    String email,
    String code,
    String newPassword,
  ) => caller.callServerEndpoint<void>(
    'userAuth',
    'confirmPasswordReset',
    {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    },
  );
}

/// Admin-only API for managing end-user accounts.
/// {@category Endpoint}
class EndpointUsers extends _i1.EndpointRef {
  EndpointUsers(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'users';

  _i2.Future<List<_i11.AppUser>> list({
    required int page,
    required int perPage,
  }) => caller.callServerEndpoint<List<_i11.AppUser>>(
    'users',
    'list',
    {
      'page': page,
      'perPage': perPage,
    },
  );

  _i2.Future<int> count() => caller.callServerEndpoint<int>(
    'users',
    'count',
    {},
  );

  _i2.Future<int> sessionCount(int userId) => caller.callServerEndpoint<int>(
    'users',
    'sessionCount',
    {'userId': userId},
  );

  _i2.Future<void> revokeSessions(int userId) =>
      caller.callServerEndpoint<void>(
        'users',
        'revokeSessions',
        {'userId': userId},
      );

  _i2.Future<void> delete(int userId) => caller.callServerEndpoint<void>(
    'users',
    'delete',
    {'userId': userId},
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i12.Caller(client);
    serverpod_auth_core = _i13.Caller(client);
  }

  late final _i12.Caller serverpod_auth_idp;

  late final _i13.Caller serverpod_auth_core;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i14.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    adminAuth = EndpointAdminAuth(this);
    admins = EndpointAdmins(this);
    collections = EndpointCollections(this);
    files = EndpointFiles(this);
    records = EndpointRecords(this);
    emails = EndpointEmails(this);
    greeting = EndpointGreeting(this);
    logs = EndpointLogs(this);
    oAuthConfig = EndpointOAuthConfig(this);
    oAuth = EndpointOAuth(this);
    posts = EndpointPosts(this);
    userAuth = EndpointUserAuth(this);
    users = EndpointUsers(this);
    modules = Modules(this);
  }

  late final EndpointAdminAuth adminAuth;

  late final EndpointAdmins admins;

  late final EndpointCollections collections;

  late final EndpointFiles files;

  late final EndpointRecords records;

  late final EndpointEmails emails;

  late final EndpointGreeting greeting;

  late final EndpointLogs logs;

  late final EndpointOAuthConfig oAuthConfig;

  late final EndpointOAuth oAuth;

  late final EndpointPosts posts;

  late final EndpointUserAuth userAuth;

  late final EndpointUsers users;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'adminAuth': adminAuth,
    'admins': admins,
    'collections': collections,
    'files': files,
    'records': records,
    'emails': emails,
    'greeting': greeting,
    'logs': logs,
    'oAuthConfig': oAuthConfig,
    'oAuth': oAuth,
    'posts': posts,
    'userAuth': userAuth,
    'users': users,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
