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

/// Transport DTO used when a caller asks the server to create a new collection.
/// Not backed by a table — just a serializable shape over the wire.
abstract class CollectionFieldSpec implements _i1.SerializableModel {
  CollectionFieldSpec._({
    required this.name,
    required this.fieldType,
    required this.required,
  });

  factory CollectionFieldSpec({
    required String name,
    required String fieldType,
    required bool required,
  }) = _CollectionFieldSpecImpl;

  factory CollectionFieldSpec.fromJson(Map<String, dynamic> jsonSerialization) {
    return CollectionFieldSpec(
      name: jsonSerialization['name'] as String,
      fieldType: jsonSerialization['fieldType'] as String,
      required: _i1.BoolJsonExtension.fromJson(jsonSerialization['required']),
    );
  }

  String name;

  String fieldType;

  bool required;

  /// Returns a shallow copy of this [CollectionFieldSpec]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CollectionFieldSpec copyWith({
    String? name,
    String? fieldType,
    bool? required,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CollectionFieldSpec',
      'name': name,
      'fieldType': fieldType,
      'required': required,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CollectionFieldSpecImpl extends CollectionFieldSpec {
  _CollectionFieldSpecImpl({
    required String name,
    required String fieldType,
    required bool required,
  }) : super._(
         name: name,
         fieldType: fieldType,
         required: required,
       );

  /// Returns a shallow copy of this [CollectionFieldSpec]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CollectionFieldSpec copyWith({
    String? name,
    String? fieldType,
    bool? required,
  }) {
    return CollectionFieldSpec(
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      required: required ?? this.required,
    );
  }
}
