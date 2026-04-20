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
import '../errors/spod_lite_error_code.dart' as _i2;

/// Every client-visible error thrown by a Serverpod Lite endpoint.
/// Serializable so the message + code travel to the client rather than
/// getting swallowed into a generic 500.
abstract class SpodLiteException
    implements _i1.SerializableException, _i1.SerializableModel {
  SpodLiteException._({
    required this.message,
    required this.code,
  });

  factory SpodLiteException({
    required String message,
    required _i2.SpodLiteErrorCode code,
  }) = _SpodLiteExceptionImpl;

  factory SpodLiteException.fromJson(Map<String, dynamic> jsonSerialization) {
    return SpodLiteException(
      message: jsonSerialization['message'] as String,
      code: _i2.SpodLiteErrorCode.fromJson(
        (jsonSerialization['code'] as String),
      ),
    );
  }

  String message;

  _i2.SpodLiteErrorCode code;

  /// Returns a shallow copy of this [SpodLiteException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SpodLiteException copyWith({
    String? message,
    _i2.SpodLiteErrorCode? code,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SpodLiteException',
      'message': message,
      'code': code.toJson(),
    };
  }

  @override
  String toString() {
    return 'SpodLiteException(message: $message, code: $code)';
  }
}

class _SpodLiteExceptionImpl extends SpodLiteException {
  _SpodLiteExceptionImpl({
    required String message,
    required _i2.SpodLiteErrorCode code,
  }) : super._(
         message: message,
         code: code,
       );

  /// Returns a shallow copy of this [SpodLiteException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SpodLiteException copyWith({
    String? message,
    _i2.SpodLiteErrorCode? code,
  }) {
    return SpodLiteException(
      message: message ?? this.message,
      code: code ?? this.code,
    );
  }
}
