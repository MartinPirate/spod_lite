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

/// A session token issued to an app end-user after sign-in.
abstract class AppSession implements _i1.SerializableModel {
  AppSession._({
    this.id,
    required this.token,
    required this.appUserId,
    this.createdAt,
    required this.expiresAt,
  });

  factory AppSession({
    int? id,
    required String token,
    required int appUserId,
    DateTime? createdAt,
    required DateTime expiresAt,
  }) = _AppSessionImpl;

  factory AppSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppSession(
      id: jsonSerialization['id'] as int?,
      token: jsonSerialization['token'] as String,
      appUserId: jsonSerialization['appUserId'] as int,
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

  int appUserId;

  DateTime? createdAt;

  DateTime expiresAt;

  /// Returns a shallow copy of this [AppSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AppSession copyWith({
    int? id,
    String? token,
    int? appUserId,
    DateTime? createdAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppSession',
      if (id != null) 'id': id,
      'token': token,
      'appUserId': appUserId,
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

class _AppSessionImpl extends AppSession {
  _AppSessionImpl({
    int? id,
    required String token,
    required int appUserId,
    DateTime? createdAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         token: token,
         appUserId: appUserId,
         createdAt: createdAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [AppSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AppSession copyWith({
    Object? id = _Undefined,
    String? token,
    int? appUserId,
    Object? createdAt = _Undefined,
    DateTime? expiresAt,
  }) {
    return AppSession(
      id: id is int? ? id : this.id,
      token: token ?? this.token,
      appUserId: appUserId ?? this.appUserId,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
