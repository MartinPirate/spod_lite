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

/// A user-defined collection. Each row corresponds to a dynamic `collection_<name>` table in Postgres.
abstract class CollectionDef implements _i1.SerializableModel {
  CollectionDef._({
    this.id,
    required this.name,
    required this.label,
    this.createdAt,
  });

  factory CollectionDef({
    int? id,
    required String name,
    required String label,
    DateTime? createdAt,
  }) = _CollectionDefImpl;

  factory CollectionDef.fromJson(Map<String, dynamic> jsonSerialization) {
    return CollectionDef(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      label: jsonSerialization['label'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  String label;

  DateTime? createdAt;

  /// Returns a shallow copy of this [CollectionDef]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CollectionDef copyWith({
    int? id,
    String? name,
    String? label,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CollectionDef',
      if (id != null) 'id': id,
      'name': name,
      'label': label,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CollectionDefImpl extends CollectionDef {
  _CollectionDefImpl({
    int? id,
    required String name,
    required String label,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         label: label,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CollectionDef]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CollectionDef copyWith({
    Object? id = _Undefined,
    String? name,
    String? label,
    Object? createdAt = _Undefined,
  }) {
    return CollectionDef(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
