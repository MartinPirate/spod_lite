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

/// Stable error taxonomy surfaced on [SpodLiteException].
enum SpodLiteErrorCode implements _i1.SerializableModel {
  invalidInput,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  rateLimited;

  static SpodLiteErrorCode fromJson(String name) {
    switch (name) {
      case 'invalidInput':
        return SpodLiteErrorCode.invalidInput;
      case 'unauthorized':
        return SpodLiteErrorCode.unauthorized;
      case 'forbidden':
        return SpodLiteErrorCode.forbidden;
      case 'notFound':
        return SpodLiteErrorCode.notFound;
      case 'conflict':
        return SpodLiteErrorCode.conflict;
      case 'rateLimited':
        return SpodLiteErrorCode.rateLimited;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "SpodLiteErrorCode"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
