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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'admin/admin_session.dart' as _i5;
import 'admin/admin_user.dart' as _i6;
import 'collections/collection_def.dart' as _i7;
import 'collections/collection_field.dart' as _i8;
import 'collections/collection_field_spec.dart' as _i9;
import 'collections/record_event.dart' as _i10;
import 'greetings/greeting.dart' as _i11;
import 'posts/post.dart' as _i12;
import 'users/app_session.dart' as _i13;
import 'users/app_user.dart' as _i14;
import 'package:spod_lite_server/src/generated/collections/collection_def.dart'
    as _i15;
import 'package:spod_lite_server/src/generated/collections/collection_field.dart'
    as _i16;
import 'package:spod_lite_server/src/generated/posts/post.dart' as _i17;
export 'admin/admin_session.dart';
export 'admin/admin_user.dart';
export 'collections/collection_def.dart';
export 'collections/collection_field.dart';
export 'collections/collection_field_spec.dart';
export 'collections/record_event.dart';
export 'greetings/greeting.dart';
export 'posts/post.dart';
export 'users/app_session.dart';
export 'users/app_user.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'admin_session',
      dartName: 'AdminSession',
      schema: 'public',
      module: 'spod_lite',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'admin_session_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'token',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'adminUserId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'expiresAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'admin_session_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'admin_session_token_uidx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'token',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'admin_user',
      dartName: 'AdminUser',
      schema: 'public',
      module: 'spod_lite',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'admin_user_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'email',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'passwordHash',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'admin_user_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'admin_user_email_uidx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'email',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'app_session',
      dartName: 'AppSession',
      schema: 'public',
      module: 'spod_lite',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'app_session_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'token',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'appUserId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'expiresAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'app_session_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'app_session_token_uidx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'token',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'app_session_user_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'appUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'app_user',
      dartName: 'AppUser',
      schema: 'public',
      module: 'spod_lite',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'app_user_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'email',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'passwordHash',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'app_user_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'app_user_email_uidx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'email',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'collection_def',
      dartName: 'CollectionDef',
      schema: 'public',
      module: 'spod_lite',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'collection_def_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'label',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'listRule',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'admin\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'viewRule',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'admin\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'createRule',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'admin\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'updateRule',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'admin\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'deleteRule',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'admin\'::text',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'collection_def_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'collection_def_name_uidx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'collection_field',
      dartName: 'CollectionField',
      schema: 'public',
      module: 'spod_lite',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'collection_field_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'collectionDefId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fieldType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'required',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _i2.ColumnDefinition(
          name: 'fieldOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'collection_field_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'collection_field_name_by_collection',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'collectionDefId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'collection_field_def_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'collectionDefId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'post',
      dartName: 'Post',
      schema: 'public',
      module: 'spod_lite',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'post_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'body',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'post_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i5.AdminSession) {
      return _i5.AdminSession.fromJson(data) as T;
    }
    if (t == _i6.AdminUser) {
      return _i6.AdminUser.fromJson(data) as T;
    }
    if (t == _i7.CollectionDef) {
      return _i7.CollectionDef.fromJson(data) as T;
    }
    if (t == _i8.CollectionField) {
      return _i8.CollectionField.fromJson(data) as T;
    }
    if (t == _i9.CollectionFieldSpec) {
      return _i9.CollectionFieldSpec.fromJson(data) as T;
    }
    if (t == _i10.RecordEvent) {
      return _i10.RecordEvent.fromJson(data) as T;
    }
    if (t == _i11.Greeting) {
      return _i11.Greeting.fromJson(data) as T;
    }
    if (t == _i12.Post) {
      return _i12.Post.fromJson(data) as T;
    }
    if (t == _i13.AppSession) {
      return _i13.AppSession.fromJson(data) as T;
    }
    if (t == _i14.AppUser) {
      return _i14.AppUser.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.AdminSession?>()) {
      return (data != null ? _i5.AdminSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AdminUser?>()) {
      return (data != null ? _i6.AdminUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.CollectionDef?>()) {
      return (data != null ? _i7.CollectionDef.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.CollectionField?>()) {
      return (data != null ? _i8.CollectionField.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.CollectionFieldSpec?>()) {
      return (data != null ? _i9.CollectionFieldSpec.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.RecordEvent?>()) {
      return (data != null ? _i10.RecordEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.Greeting?>()) {
      return (data != null ? _i11.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Post?>()) {
      return (data != null ? _i12.Post.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.AppSession?>()) {
      return (data != null ? _i13.AppSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.AppUser?>()) {
      return (data != null ? _i14.AppUser.fromJson(data) : null) as T;
    }
    if (t == List<_i15.CollectionDef>) {
      return (data as List)
              .map((e) => deserialize<_i15.CollectionDef>(e))
              .toList()
          as T;
    }
    if (t == List<_i16.CollectionField>) {
      return (data as List)
              .map((e) => deserialize<_i16.CollectionField>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i17.Post>) {
      return (data as List).map((e) => deserialize<_i17.Post>(e)).toList() as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.AdminSession => 'AdminSession',
      _i6.AdminUser => 'AdminUser',
      _i7.CollectionDef => 'CollectionDef',
      _i8.CollectionField => 'CollectionField',
      _i9.CollectionFieldSpec => 'CollectionFieldSpec',
      _i10.RecordEvent => 'RecordEvent',
      _i11.Greeting => 'Greeting',
      _i12.Post => 'Post',
      _i13.AppSession => 'AppSession',
      _i14.AppUser => 'AppUser',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('spod_lite.', '');
    }

    switch (data) {
      case _i5.AdminSession():
        return 'AdminSession';
      case _i6.AdminUser():
        return 'AdminUser';
      case _i7.CollectionDef():
        return 'CollectionDef';
      case _i8.CollectionField():
        return 'CollectionField';
      case _i9.CollectionFieldSpec():
        return 'CollectionFieldSpec';
      case _i10.RecordEvent():
        return 'RecordEvent';
      case _i11.Greeting():
        return 'Greeting';
      case _i12.Post():
        return 'Post';
      case _i13.AppSession():
        return 'AppSession';
      case _i14.AppUser():
        return 'AppUser';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AdminSession') {
      return deserialize<_i5.AdminSession>(data['data']);
    }
    if (dataClassName == 'AdminUser') {
      return deserialize<_i6.AdminUser>(data['data']);
    }
    if (dataClassName == 'CollectionDef') {
      return deserialize<_i7.CollectionDef>(data['data']);
    }
    if (dataClassName == 'CollectionField') {
      return deserialize<_i8.CollectionField>(data['data']);
    }
    if (dataClassName == 'CollectionFieldSpec') {
      return deserialize<_i9.CollectionFieldSpec>(data['data']);
    }
    if (dataClassName == 'RecordEvent') {
      return deserialize<_i10.RecordEvent>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i11.Greeting>(data['data']);
    }
    if (dataClassName == 'Post') {
      return deserialize<_i12.Post>(data['data']);
    }
    if (dataClassName == 'AppSession') {
      return deserialize<_i13.AppSession>(data['data']);
    }
    if (dataClassName == 'AppUser') {
      return deserialize<_i14.AppUser>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i5.AdminSession:
        return _i5.AdminSession.t;
      case _i6.AdminUser:
        return _i6.AdminUser.t;
      case _i7.CollectionDef:
        return _i7.CollectionDef.t;
      case _i8.CollectionField:
        return _i8.CollectionField.t;
      case _i12.Post:
        return _i12.Post.t;
      case _i13.AppSession:
        return _i13.AppSession.t;
      case _i14.AppUser:
        return _i14.AppUser.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'spod_lite';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
