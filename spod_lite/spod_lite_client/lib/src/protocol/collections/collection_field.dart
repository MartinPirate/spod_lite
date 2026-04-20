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

/// A field on a user-defined collection. Mirrors a column in `collection_<name>`.
abstract class CollectionField implements _i1.SerializableModel {
  CollectionField._({
    this.id,
    required this.collectionDefId,
    required this.name,
    required this.fieldType,
    bool? required,
    int? fieldOrder,
  }) : required = required ?? false,
       fieldOrder = fieldOrder ?? 0;

  factory CollectionField({
    int? id,
    required int collectionDefId,
    required String name,
    required String fieldType,
    bool? required,
    int? fieldOrder,
  }) = _CollectionFieldImpl;

  factory CollectionField.fromJson(Map<String, dynamic> jsonSerialization) {
    return CollectionField(
      id: jsonSerialization['id'] as int?,
      collectionDefId: jsonSerialization['collectionDefId'] as int,
      name: jsonSerialization['name'] as String,
      fieldType: jsonSerialization['fieldType'] as String,
      required: jsonSerialization['required'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['required']),
      fieldOrder: jsonSerialization['fieldOrder'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int collectionDefId;

  String name;

  String fieldType;

  bool required;

  int fieldOrder;

  /// Returns a shallow copy of this [CollectionField]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CollectionField copyWith({
    int? id,
    int? collectionDefId,
    String? name,
    String? fieldType,
    bool? required,
    int? fieldOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CollectionField',
      if (id != null) 'id': id,
      'collectionDefId': collectionDefId,
      'name': name,
      'fieldType': fieldType,
      'required': required,
      'fieldOrder': fieldOrder,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CollectionFieldImpl extends CollectionField {
  _CollectionFieldImpl({
    int? id,
    required int collectionDefId,
    required String name,
    required String fieldType,
    bool? required,
    int? fieldOrder,
  }) : super._(
         id: id,
         collectionDefId: collectionDefId,
         name: name,
         fieldType: fieldType,
         required: required,
         fieldOrder: fieldOrder,
       );

  /// Returns a shallow copy of this [CollectionField]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CollectionField copyWith({
    Object? id = _Undefined,
    int? collectionDefId,
    String? name,
    String? fieldType,
    bool? required,
    int? fieldOrder,
  }) {
    return CollectionField(
      id: id is int? ? id : this.id,
      collectionDefId: collectionDefId ?? this.collectionDefId,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      required: required ?? this.required,
      fieldOrder: fieldOrder ?? this.fieldOrder,
    );
  }
}
