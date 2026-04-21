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
import '../admin/admins_endpoint.dart' as _i3;
import '../collections/collections_endpoint.dart' as _i4;
import '../collections/files_endpoint.dart' as _i5;
import '../collections/records_endpoint.dart' as _i6;
import '../emails/emails_endpoint.dart' as _i7;
import '../greetings/greeting_endpoint.dart' as _i8;
import '../logs/logs_endpoint.dart' as _i9;
import '../posts/posts_endpoint.dart' as _i10;
import '../users/user_auth_endpoint.dart' as _i11;
import '../users/users_endpoint.dart' as _i12;
import 'dart:typed_data' as _i13;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i14;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i15;

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
      'admins': _i3.AdminsEndpoint()
        ..initialize(
          server,
          'admins',
          null,
        ),
      'collections': _i4.CollectionsEndpoint()
        ..initialize(
          server,
          'collections',
          null,
        ),
      'files': _i5.FilesEndpoint()
        ..initialize(
          server,
          'files',
          null,
        ),
      'records': _i6.RecordsEndpoint()
        ..initialize(
          server,
          'records',
          null,
        ),
      'emails': _i7.EmailsEndpoint()
        ..initialize(
          server,
          'emails',
          null,
        ),
      'greeting': _i8.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'logs': _i9.LogsEndpoint()
        ..initialize(
          server,
          'logs',
          null,
        ),
      'posts': _i10.PostsEndpoint()
        ..initialize(
          server,
          'posts',
          null,
        ),
      'userAuth': _i11.UserAuthEndpoint()
        ..initialize(
          server,
          'userAuth',
          null,
        ),
      'users': _i12.UsersEndpoint()
        ..initialize(
          server,
          'users',
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
    connectors['admins'] = _i1.EndpointConnector(
      name: 'admins',
      endpoint: endpoints['admins']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admins'] as _i3.AdminsEndpoint).list(session),
        ),
        'count': _i1.MethodConnector(
          name: 'count',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admins'] as _i3.AdminsEndpoint).count(session),
        ),
        'invite': _i1.MethodConnector(
          name: 'invite',
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
              ) async => (endpoints['admins'] as _i3.AdminsEndpoint).invite(
                session,
                params['email'],
                params['password'],
              ),
        ),
        'revoke': _i1.MethodConnector(
          name: 'revoke',
          params: {
            'adminId': _i1.ParameterDescription(
              name: 'adminId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admins'] as _i3.AdminsEndpoint).revoke(
                session,
                params['adminId'],
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
              ) async => (endpoints['collections'] as _i4.CollectionsEndpoint)
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
                  (endpoints['collections'] as _i4.CollectionsEndpoint).get(
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
                  (endpoints['collections'] as _i4.CollectionsEndpoint).fields(
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
                  (endpoints['collections'] as _i4.CollectionsEndpoint).create(
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
                  (endpoints['collections'] as _i4.CollectionsEndpoint).delete(
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
              ) async => (endpoints['collections'] as _i4.CollectionsEndpoint)
                  .updateRules(
                    session,
                    params['name'],
                    params['rulesJson'],
                  ),
        ),
      },
    );
    connectors['files'] = _i1.EndpointConnector(
      name: 'files',
      endpoint: endpoints['files']!,
      methodConnectors: {
        'upload': _i1.MethodConnector(
          name: 'upload',
          params: {
            'collectionName': _i1.ParameterDescription(
              name: 'collectionName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'recordId': _i1.ParameterDescription(
              name: 'recordId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'fieldName': _i1.ParameterDescription(
              name: 'fieldName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'bytes': _i1.ParameterDescription(
              name: 'bytes',
              type: _i1.getType<_i13.ByteData>(),
              nullable: false,
            ),
            'filename': _i1.ParameterDescription(
              name: 'filename',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['files'] as _i5.FilesEndpoint).upload(
                session,
                params['collectionName'],
                params['recordId'],
                params['fieldName'],
                params['bytes'],
                params['filename'],
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
            'recordId': _i1.ParameterDescription(
              name: 'recordId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'fieldName': _i1.ParameterDescription(
              name: 'fieldName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['files'] as _i5.FilesEndpoint).delete(
                session,
                params['collectionName'],
                params['recordId'],
                params['fieldName'],
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
              ) async => (endpoints['records'] as _i6.RecordsEndpoint).list(
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
              ) async => (endpoints['records'] as _i6.RecordsEndpoint).count(
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
              ) async => (endpoints['records'] as _i6.RecordsEndpoint).get(
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
              ) async => (endpoints['records'] as _i6.RecordsEndpoint).create(
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
              ) async => (endpoints['records'] as _i6.RecordsEndpoint).update(
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
              ) async => (endpoints['records'] as _i6.RecordsEndpoint).delete(
                session,
                params['collectionName'],
                params['id'],
              ),
        ),
        'watch': _i1.MethodStreamConnector(
          name: 'watch',
          params: {
            'collectionName': _i1.ParameterDescription(
              name: 'collectionName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['records'] as _i6.RecordsEndpoint).watch(
                session,
                params['collectionName'],
              ),
        ),
      },
    );
    connectors['emails'] = _i1.EndpointConnector(
      name: 'emails',
      endpoint: endpoints['emails']!,
      methodConnectors: {
        'driverName': _i1.MethodConnector(
          name: 'driverName',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emails'] as _i7.EmailsEndpoint).driverName(
                session,
              ),
        ),
        'sendTest': _i1.MethodConnector(
          name: 'sendTest',
          params: {
            'to': _i1.ParameterDescription(
              name: 'to',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'subject': _i1.ParameterDescription(
              name: 'subject',
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
              ) async => (endpoints['emails'] as _i7.EmailsEndpoint).sendTest(
                session,
                params['to'],
                params['subject'],
                params['body'],
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
              ) async => (endpoints['greeting'] as _i8.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    connectors['logs'] = _i1.EndpointConnector(
      name: 'logs',
      endpoint: endpoints['logs']!,
      methodConnectors: {
        'recent': _i1.MethodConnector(
          name: 'recent',
          params: {
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['logs'] as _i9.LogsEndpoint).recent(
                session,
                params['limit'],
              ),
        ),
        'count': _i1.MethodConnector(
          name: 'count',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['logs'] as _i9.LogsEndpoint).count(session),
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
                  (endpoints['posts'] as _i10.PostsEndpoint).listPosts(session),
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
              ) async => (endpoints['posts'] as _i10.PostsEndpoint).createPost(
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
              ) async => (endpoints['posts'] as _i10.PostsEndpoint).deletePost(
                session,
                params['id'],
              ),
        ),
        'watchPosts': _i1.MethodStreamConnector(
          name: 'watchPosts',
          params: {},
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['posts'] as _i10.PostsEndpoint).watchPosts(
                session,
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
              ) async =>
                  (endpoints['userAuth'] as _i11.UserAuthEndpoint).signUp(
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
                  (endpoints['userAuth'] as _i11.UserAuthEndpoint).signIn(
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
              ) async => (endpoints['userAuth'] as _i11.UserAuthEndpoint).me(
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
                  (endpoints['userAuth'] as _i11.UserAuthEndpoint).signOut(
                    session,
                    params['token'],
                  ),
        ),
        'requestEmailVerification': _i1.MethodConnector(
          name: 'requestEmailVerification',
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
              ) async => (endpoints['userAuth'] as _i11.UserAuthEndpoint)
                  .requestEmailVerification(
                    session,
                    params['token'],
                  ),
        ),
        'verifyEmail': _i1.MethodConnector(
          name: 'verifyEmail',
          params: {
            'token': _i1.ParameterDescription(
              name: 'token',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'code': _i1.ParameterDescription(
              name: 'code',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['userAuth'] as _i11.UserAuthEndpoint).verifyEmail(
                    session,
                    params['token'],
                    params['code'],
                  ),
        ),
        'requestPasswordReset': _i1.MethodConnector(
          name: 'requestPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['userAuth'] as _i11.UserAuthEndpoint)
                  .requestPasswordReset(
                    session,
                    params['email'],
                  ),
        ),
        'confirmPasswordReset': _i1.MethodConnector(
          name: 'confirmPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'code': _i1.ParameterDescription(
              name: 'code',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['userAuth'] as _i11.UserAuthEndpoint)
                  .confirmPasswordReset(
                    session,
                    params['email'],
                    params['code'],
                    params['newPassword'],
                  ),
        ),
      },
    );
    connectors['users'] = _i1.EndpointConnector(
      name: 'users',
      endpoint: endpoints['users']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
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
              ) async => (endpoints['users'] as _i12.UsersEndpoint).list(
                session,
                page: params['page'],
                perPage: params['perPage'],
              ),
        ),
        'count': _i1.MethodConnector(
          name: 'count',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['users'] as _i12.UsersEndpoint).count(session),
        ),
        'sessionCount': _i1.MethodConnector(
          name: 'sessionCount',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['users'] as _i12.UsersEndpoint).sessionCount(
                    session,
                    params['userId'],
                  ),
        ),
        'revokeSessions': _i1.MethodConnector(
          name: 'revokeSessions',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['users'] as _i12.UsersEndpoint).revokeSessions(
                    session,
                    params['userId'],
                  ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['users'] as _i12.UsersEndpoint).delete(
                session,
                params['userId'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i14.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i15.Endpoints()
      ..initializeEndpoints(server);
  }
}
