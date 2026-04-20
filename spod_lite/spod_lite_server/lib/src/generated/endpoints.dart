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
import 'package:serverpod/serverpod.dart' as _i1;
import '../admin/admin_auth_endpoint.dart' as _i2;
import '../collections/collections_endpoint.dart' as _i3;
import '../collections/records_endpoint.dart' as _i4;
import '../greetings/greeting_endpoint.dart' as _i5;
import '../posts/posts_endpoint.dart' as _i6;
import '../users/user_auth_endpoint.dart' as _i7;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i8;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i9;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'adminAuth': _i2.AdminAuthEndpoint()
        ..initialize(
          server,
          'adminAuth',
          null,
        ),
      'collections': _i3.CollectionsEndpoint()
        ..initialize(
          server,
          'collections',
          null,
        ),
      'records': _i4.RecordsEndpoint()
        ..initialize(
          server,
          'records',
          null,
        ),
      'greeting': _i5.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'posts': _i6.PostsEndpoint()
        ..initialize(
          server,
          'posts',
          null,
        ),
      'userAuth': _i7.UserAuthEndpoint()
        ..initialize(
          server,
          'userAuth',
          null,
        ),
    };
    connectors['adminAuth'] = _i1.EndpointConnector(
      name: 'adminAuth',
      endpoint: endpoints['adminAuth']!,
      methodConnectors: {
        'hasAdmins': _i1.MethodConnector(
          name: 'hasAdmins',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminAuth'] as _i2.AdminAuthEndpoint)
                  .hasAdmins(session),
        ),
        'createFirstAdmin': _i1.MethodConnector(
          name: 'createFirstAdmin',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminAuth'] as _i2.AdminAuthEndpoint)
                  .createFirstAdmin(
                    session,
                    params['email'],
                    params['password'],
                  ),
        ),
        'signIn': _i1.MethodConnector(
          name: 'signIn',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['adminAuth'] as _i2.AdminAuthEndpoint).signIn(
                    session,
                    params['email'],
                    params['password'],
                  ),
        ),
        'me': _i1.MethodConnector(
          name: 'me',
          params: {
            'token': _i1.ParameterDescription(
              name: 'token',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminAuth'] as _i2.AdminAuthEndpoint).me(
                session,
                params['token'],
              ),
        ),
        'signOut': _i1.MethodConnector(
          name: 'signOut',
          params: {
            'token': _i1.ParameterDescription(
              name: 'token',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['adminAuth'] as _i2.AdminAuthEndpoint).signOut(
                    session,
                    params['token'],
                  ),
        ),
      },
    );
    connectors['collections'] = _i1.EndpointConnector(
      name: 'collections',
      endpoint: endpoints['collections']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['collections'] as _i3.CollectionsEndpoint)
                  .list(session),
        ),
        'get': _i1.MethodConnector(
          name: 'get',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['collections'] as _i3.CollectionsEndpoint).get(
                    session,
                    params['name'],
                  ),
        ),
        'fields': _i1.MethodConnector(
          name: 'fields',
          params: {
            'collectionDefId': _i1.ParameterDescription(
              name: 'collectionDefId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['collections'] as _i3.CollectionsEndpoint).fields(
                    session,
                    params['collectionDefId'],
                  ),
        ),
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'label': _i1.ParameterDescription(
              name: 'label',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'specsJson': _i1.ParameterDescription(
              name: 'specsJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['collections'] as _i3.CollectionsEndpoint).create(
                    session,
                    params['name'],
                    params['label'],
                    params['specsJson'],
                  ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['collections'] as _i3.CollectionsEndpoint).delete(
                    session,
                    params['name'],
                  ),
        ),
        'updateRules': _i1.MethodConnector(
          name: 'updateRules',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'rulesJson': _i1.ParameterDescription(
              name: 'rulesJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['collections'] as _i3.CollectionsEndpoint)
                  .updateRules(
                    session,
                    params['name'],
                    params['rulesJson'],
                  ),
        ),
      },
    );
    connectors['records'] = _i1.EndpointConnector(
      name: 'records',
      endpoint: endpoints['records']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'collectionName': _i1.ParameterDescription(
              name: 'collectionName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'page': _i1.ParameterDescription(
              name: 'page',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'perPage': _i1.ParameterDescription(
              name: 'perPage',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['records'] as _i4.RecordsEndpoint).list(
                session,
                params['collectionName'],
                params['page'],
                params['perPage'],
              ),
        ),
        'count': _i1.MethodConnector(
          name: 'count',
          params: {
            'collectionName': _i1.ParameterDescription(
              name: 'collectionName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['records'] as _i4.RecordsEndpoint).count(
                session,
                params['collectionName'],
              ),
        ),
        'get': _i1.MethodConnector(
          name: 'get',
          params: {
            'collectionName': _i1.ParameterDescription(
              name: 'collectionName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['records'] as _i4.RecordsEndpoint).get(
                session,
                params['collectionName'],
                params['id'],
              ),
        ),
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'collectionName': _i1.ParameterDescription(
              name: 'collectionName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'dataJson': _i1.ParameterDescription(
              name: 'dataJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['records'] as _i4.RecordsEndpoint).create(
                session,
                params['collectionName'],
                params['dataJson'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'collectionName': _i1.ParameterDescription(
              name: 'collectionName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'dataJson': _i1.ParameterDescription(
              name: 'dataJson',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['records'] as _i4.RecordsEndpoint).update(
                session,
                params['collectionName'],
                params['id'],
                params['dataJson'],
              ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'collectionName': _i1.ParameterDescription(
              name: 'collectionName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['records'] as _i4.RecordsEndpoint).delete(
                session,
                params['collectionName'],
                params['id'],
              ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i5.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    connectors['posts'] = _i1.EndpointConnector(
      name: 'posts',
      endpoint: endpoints['posts']!,
      methodConnectors: {
        'listPosts': _i1.MethodConnector(
          name: 'listPosts',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['posts'] as _i6.PostsEndpoint).listPosts(session),
        ),
        'createPost': _i1.MethodConnector(
          name: 'createPost',
          params: {
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'body': _i1.ParameterDescription(
              name: 'body',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['posts'] as _i6.PostsEndpoint).createPost(
                session,
                params['title'],
                params['body'],
              ),
        ),
        'deletePost': _i1.MethodConnector(
          name: 'deletePost',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['posts'] as _i6.PostsEndpoint).deletePost(
                session,
                params['id'],
              ),
        ),
      },
    );
    connectors['userAuth'] = _i1.EndpointConnector(
      name: 'userAuth',
      endpoint: endpoints['userAuth']!,
      methodConnectors: {
        'signUp': _i1.MethodConnector(
          name: 'signUp',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['userAuth'] as _i7.UserAuthEndpoint).signUp(
                session,
                params['email'],
                params['password'],
              ),
        ),
        'signIn': _i1.MethodConnector(
          name: 'signIn',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['userAuth'] as _i7.UserAuthEndpoint).signIn(
                session,
                params['email'],
                params['password'],
              ),
        ),
        'me': _i1.MethodConnector(
          name: 'me',
          params: {
            'token': _i1.ParameterDescription(
              name: 'token',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['userAuth'] as _i7.UserAuthEndpoint).me(
                session,
                params['token'],
              ),
        ),
        'signOut': _i1.MethodConnector(
          name: 'signOut',
          params: {
            'token': _i1.ParameterDescription(
              name: 'token',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['userAuth'] as _i7.UserAuthEndpoint).signOut(
                    session,
                    params['token'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i8.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i9.Endpoints()
      ..initializeEndpoints(server);
  }
}
