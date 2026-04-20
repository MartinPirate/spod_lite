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

/// A dashboard session token issued after successful admin sign-in.
abstract class AdminSession implements _i1.SerializableModel {
  AdminSession._({
    this.id,
    required this.token,
    required this.adminUserId,
    this.createdAt,
    required this.expiresAt,
  });

  factory AdminSession({
    int? id,
    required String token,
    required int adminUserId,
    DateTime? createdAt,
    required DateTime expiresAt,
  }) = _AdminSessionImpl;

  factory AdminSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminSession(
      id: jsonSerialization['id'] as int?,
      token: jsonSerialization['token'] as String,
      adminUserId: jsonSerialization['adminUserId'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String token;

  int adminUserId;

  DateTime? createdAt;

  DateTime expiresAt;

  /// Returns a shallow copy of this [AdminSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminSession copyWith({
    int? id,
    String? token,
    int? adminUserId,
    DateTime? createdAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminSession',
      if (id != null) 'id': id,
      'token': token,
      'adminUserId': adminUserId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminSessionImpl extends AdminSession {
  _AdminSessionImpl({
    int? id,
    required String token,
    required int adminUserId,
    DateTime? createdAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         token: token,
         adminUserId: adminUserId,
         createdAt: createdAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [AdminSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminSession copyWith({
    Object? id = _Undefined,
    String? token,
    int? adminUserId,
    Object? createdAt = _Undefined,
    DateTime? expiresAt,
  }) {
    return AdminSession(
      id: id is int? ? id : this.id,
      token: token ?? this.token,
      adminUserId: adminUserId ?? this.adminUserId,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
