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
import 'admin/admin_session.dart' as _i2;
import 'admin/admin_user.dart' as _i3;
import 'collections/collection_def.dart' as _i4;
import 'collections/collection_field.dart' as _i5;
import 'collections/collection_field_spec.dart' as _i6;
import 'collections/record_event.dart' as _i7;
import 'errors/spod_lite_error_code.dart' as _i8;
import 'errors/spod_lite_exception.dart' as _i9;
import 'greetings/greeting.dart' as _i10;
import 'posts/post.dart' as _i11;
import 'users/app_session.dart' as _i12;
import 'users/app_user.dart' as _i13;
import 'package:spod_lite_client/src/protocol/admin/admin_user.dart' as _i14;
import 'package:spod_lite_client/src/protocol/collections/collection_def.dart'
    as _i15;
import 'package:spod_lite_client/src/protocol/collections/collection_field.dart'
    as _i16;
import 'package:spod_lite_client/src/protocol/posts/post.dart' as _i17;
import 'package:spod_lite_client/src/protocol/users/app_user.dart' as _i18;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i19;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i20;
export 'admin/admin_session.dart';
export 'admin/admin_user.dart';
export 'collections/collection_def.dart';
export 'collections/collection_field.dart';
export 'collections/collection_field_spec.dart';
export 'collections/record_event.dart';
export 'errors/spod_lite_error_code.dart';
export 'errors/spod_lite_exception.dart';
export 'greetings/greeting.dart';
export 'posts/post.dart';
export 'users/app_session.dart';
export 'users/app_user.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

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

    if (t == _i2.AdminSession) {
      return _i2.AdminSession.fromJson(data) as T;
    }
    if (t == _i3.AdminUser) {
      return _i3.AdminUser.fromJson(data) as T;
    }
    if (t == _i4.CollectionDef) {
      return _i4.CollectionDef.fromJson(data) as T;
    }
    if (t == _i5.CollectionField) {
      return _i5.CollectionField.fromJson(data) as T;
    }
    if (t == _i6.CollectionFieldSpec) {
      return _i6.CollectionFieldSpec.fromJson(data) as T;
    }
    if (t == _i7.RecordEvent) {
      return _i7.RecordEvent.fromJson(data) as T;
    }
    if (t == _i8.SpodLiteErrorCode) {
      return _i8.SpodLiteErrorCode.fromJson(data) as T;
    }
    if (t == _i9.SpodLiteException) {
      return _i9.SpodLiteException.fromJson(data) as T;
    }
    if (t == _i10.Greeting) {
      return _i10.Greeting.fromJson(data) as T;
    }
    if (t == _i11.Post) {
      return _i11.Post.fromJson(data) as T;
    }
    if (t == _i12.AppSession) {
      return _i12.AppSession.fromJson(data) as T;
    }
    if (t == _i13.AppUser) {
      return _i13.AppUser.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AdminSession?>()) {
      return (data != null ? _i2.AdminSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AdminUser?>()) {
      return (data != null ? _i3.AdminUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.CollectionDef?>()) {
      return (data != null ? _i4.CollectionDef.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.CollectionField?>()) {
      return (data != null ? _i5.CollectionField.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.CollectionFieldSpec?>()) {
      return (data != null ? _i6.CollectionFieldSpec.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.RecordEvent?>()) {
      return (data != null ? _i7.RecordEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.SpodLiteErrorCode?>()) {
      return (data != null ? _i8.SpodLiteErrorCode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.SpodLiteException?>()) {
      return (data != null ? _i9.SpodLiteException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Greeting?>()) {
      return (data != null ? _i10.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.Post?>()) {
      return (data != null ? _i11.Post.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.AppSession?>()) {
      return (data != null ? _i12.AppSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.AppUser?>()) {
      return (data != null ? _i13.AppUser.fromJson(data) : null) as T;
    }
    if (t == List<_i14.AdminUser>) {
      return (data as List).map((e) => deserialize<_i14.AdminUser>(e)).toList()
          as T;
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
    if (t == List<_i18.AppUser>) {
      return (data as List).map((e) => deserialize<_i18.AppUser>(e)).toList()
          as T;
    }
    try {
      return _i19.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i20.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AdminSession => 'AdminSession',
      _i3.AdminUser => 'AdminUser',
      _i4.CollectionDef => 'CollectionDef',
      _i5.CollectionField => 'CollectionField',
      _i6.CollectionFieldSpec => 'CollectionFieldSpec',
      _i7.RecordEvent => 'RecordEvent',
      _i8.SpodLiteErrorCode => 'SpodLiteErrorCode',
      _i9.SpodLiteException => 'SpodLiteException',
      _i10.Greeting => 'Greeting',
      _i11.Post => 'Post',
      _i12.AppSession => 'AppSession',
      _i13.AppUser => 'AppUser',
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
      case _i2.AdminSession():
        return 'AdminSession';
      case _i3.AdminUser():
        return 'AdminUser';
      case _i4.CollectionDef():
        return 'CollectionDef';
      case _i5.CollectionField():
        return 'CollectionField';
      case _i6.CollectionFieldSpec():
        return 'CollectionFieldSpec';
      case _i7.RecordEvent():
        return 'RecordEvent';
      case _i8.SpodLiteErrorCode():
        return 'SpodLiteErrorCode';
      case _i9.SpodLiteException():
        return 'SpodLiteException';
      case _i10.Greeting():
        return 'Greeting';
      case _i11.Post():
        return 'Post';
      case _i12.AppSession():
        return 'AppSession';
      case _i13.AppUser():
        return 'AppUser';
    }
    className = _i19.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i20.Protocol().getClassNameForObject(data);
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
      return deserialize<_i2.AdminSession>(data['data']);
    }
    if (dataClassName == 'AdminUser') {
      return deserialize<_i3.AdminUser>(data['data']);
    }
    if (dataClassName == 'CollectionDef') {
      return deserialize<_i4.CollectionDef>(data['data']);
    }
    if (dataClassName == 'CollectionField') {
      return deserialize<_i5.CollectionField>(data['data']);
    }
    if (dataClassName == 'CollectionFieldSpec') {
      return deserialize<_i6.CollectionFieldSpec>(data['data']);
    }
    if (dataClassName == 'RecordEvent') {
      return deserialize<_i7.RecordEvent>(data['data']);
    }
    if (dataClassName == 'SpodLiteErrorCode') {
      return deserialize<_i8.SpodLiteErrorCode>(data['data']);
    }
    if (dataClassName == 'SpodLiteException') {
      return deserialize<_i9.SpodLiteException>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i10.Greeting>(data['data']);
    }
    if (dataClassName == 'Post') {
      return deserialize<_i11.Post>(data['data']);
    }
    if (dataClassName == 'AppSession') {
      return deserialize<_i12.AppSession>(data['data']);
    }
    if (dataClassName == 'AppUser') {
      return deserialize<_i13.AppUser>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i19.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i20.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

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
      return _i19.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i20.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
