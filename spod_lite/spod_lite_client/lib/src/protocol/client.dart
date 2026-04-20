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
import 'package:spod_lite_client/src/protocol/collections/record_event.dart'
    as _i6;
import 'package:spod_lite_client/src/protocol/greetings/greeting.dart' as _i7;
import 'package:spod_lite_client/src/protocol/posts/post.dart' as _i8;
import 'package:spod_lite_client/src/protocol/users/app_user.dart' as _i9;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i10;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i11;
import 'protocol.dart' as _i12;

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
  /// rule as `list`.
  _i2.Stream<_i6.RecordEvent> watch(String collectionName) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i6.RecordEvent>,
        _i6.RecordEvent
      >(
        'records',
        'watch',
        {'collectionName': collectionName},
        {},
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
  _i2.Future<_i7.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i7.Greeting>(
        'greeting',
        'hello',
        {'name': name},
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

  _i2.Future<List<_i8.Post>> listPosts() =>
      caller.callServerEndpoint<List<_i8.Post>>(
        'posts',
        'listPosts',
        {},
      );

  _i2.Future<_i8.Post> createPost(
    String title,
    String body,
  ) => caller.callServerEndpoint<_i8.Post>(
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
  _i2.Stream<_i8.Post> watchPosts() =>
      caller.callStreamingServerEndpoint<_i2.Stream<_i8.Post>, _i8.Post>(
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

  _i2.Future<_i9.AppUser?> me(String token) =>
      caller.callServerEndpoint<_i9.AppUser?>(
        'userAuth',
        'me',
        {'token': token},
      );

  _i2.Future<void> signOut(String token) => caller.callServerEndpoint<void>(
    'userAuth',
    'signOut',
    {'token': token},
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i10.Caller(client);
    serverpod_auth_core = _i11.Caller(client);
  }

  late final _i10.Caller serverpod_auth_idp;

  late final _i11.Caller serverpod_auth_core;
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
         _i12.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    adminAuth = EndpointAdminAuth(this);
    collections = EndpointCollections(this);
    records = EndpointRecords(this);
    greeting = EndpointGreeting(this);
    posts = EndpointPosts(this);
    userAuth = EndpointUserAuth(this);
    modules = Modules(this);
  }

  late final EndpointAdminAuth adminAuth;

  late final EndpointCollections collections;

  late final EndpointRecords records;

  late final EndpointGreeting greeting;

  late final EndpointPosts posts;

  late final EndpointUserAuth userAuth;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'adminAuth': adminAuth,
    'collections': collections,
    'records': records,
    'greeting': greeting,
    'posts': posts,
    'userAuth': userAuth,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
