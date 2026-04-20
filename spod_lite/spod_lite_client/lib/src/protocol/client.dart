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
import 'package:spod_lite_client/src/protocol/greetings/greeting.dart' as _i4;
import 'package:spod_lite_client/src/protocol/posts/post.dart' as _i5;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i6;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i7;
import 'protocol.dart' as _i8;

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

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i4.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i4.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// {@category Endpoint}
class EndpointPosts extends _i1.EndpointRef {
  EndpointPosts(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'posts';

  _i2.Future<List<_i5.Post>> listPosts() =>
      caller.callServerEndpoint<List<_i5.Post>>(
        'posts',
        'listPosts',
        {},
      );

  _i2.Future<_i5.Post> createPost(
    String title,
    String body,
  ) => caller.callServerEndpoint<_i5.Post>(
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
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i6.Caller(client);
    serverpod_auth_core = _i7.Caller(client);
  }

  late final _i6.Caller serverpod_auth_idp;

  late final _i7.Caller serverpod_auth_core;
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
         _i8.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    adminAuth = EndpointAdminAuth(this);
    greeting = EndpointGreeting(this);
    posts = EndpointPosts(this);
    modules = Modules(this);
  }

  late final EndpointAdminAuth adminAuth;

  late final EndpointGreeting greeting;

  late final EndpointPosts posts;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'adminAuth': adminAuth,
    'greeting': greeting,
    'posts': posts,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
