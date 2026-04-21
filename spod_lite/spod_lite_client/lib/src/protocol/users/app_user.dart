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

/// An end-user of apps built on this Serverpod Lite backend.
/// Distinct from `AdminUser` — admins run the dashboard, app users are
/// the people whose accounts the app creates.
abstract class AppUser implements _i1.SerializableModel {
  AppUser._({
    this.id,
    required this.email,
    required this.passwordHash,
    bool? emailVerified,
    this.emailVerificationCode,
    this.emailVerificationExpiresAt,
    this.passwordResetCode,
    this.passwordResetExpiresAt,
    this.createdAt,
  }) : emailVerified = emailVerified ?? false;

  factory AppUser({
    int? id,
    required String email,
    required String passwordHash,
    bool? emailVerified,
    String? emailVerificationCode,
    DateTime? emailVerificationExpiresAt,
    String? passwordResetCode,
    DateTime? passwordResetExpiresAt,
    DateTime? createdAt,
  }) = _AppUserImpl;

  factory AppUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return AppUser(
      id: jsonSerialization['id'] as int?,
      email: jsonSerialization['email'] as String,
      passwordHash: jsonSerialization['passwordHash'] as String,
      emailVerified: jsonSerialization['emailVerified'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['emailVerified']),
      emailVerificationCode:
          jsonSerialization['emailVerificationCode'] as String?,
      emailVerificationExpiresAt:
          jsonSerialization['emailVerificationExpiresAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['emailVerificationExpiresAt'],
            ),
      passwordResetCode: jsonSerialization['passwordResetCode'] as String?,
      passwordResetExpiresAt:
          jsonSerialization['passwordResetExpiresAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['passwordResetExpiresAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String email;

  String passwordHash;

  bool emailVerified;

  String? emailVerificationCode;

  DateTime? emailVerificationExpiresAt;

  String? passwordResetCode;

  DateTime? passwordResetExpiresAt;

  DateTime? createdAt;

  /// Returns a shallow copy of this [AppUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AppUser copyWith({
    int? id,
    String? email,
    String? passwordHash,
    bool? emailVerified,
    String? emailVerificationCode,
    DateTime? emailVerificationExpiresAt,
    String? passwordResetCode,
    DateTime? passwordResetExpiresAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AppUser',
      if (id != null) 'id': id,
      'email': email,
      'passwordHash': passwordHash,
      'emailVerified': emailVerified,
      if (emailVerificationCode != null)
        'emailVerificationCode': emailVerificationCode,
      if (emailVerificationExpiresAt != null)
        'emailVerificationExpiresAt': emailVerificationExpiresAt?.toJson(),
      if (passwordResetCode != null) 'passwordResetCode': passwordResetCode,
      if (passwordResetExpiresAt != null)
        'passwordResetExpiresAt': passwordResetExpiresAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AppUserImpl extends AppUser {
  _AppUserImpl({
    int? id,
    required String email,
    required String passwordHash,
    bool? emailVerified,
    String? emailVerificationCode,
    DateTime? emailVerificationExpiresAt,
    String? passwordResetCode,
    DateTime? passwordResetExpiresAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         email: email,
         passwordHash: passwordHash,
         emailVerified: emailVerified,
         emailVerificationCode: emailVerificationCode,
         emailVerificationExpiresAt: emailVerificationExpiresAt,
         passwordResetCode: passwordResetCode,
         passwordResetExpiresAt: passwordResetExpiresAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AppUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AppUser copyWith({
    Object? id = _Undefined,
    String? email,
    String? passwordHash,
    bool? emailVerified,
    Object? emailVerificationCode = _Undefined,
    Object? emailVerificationExpiresAt = _Undefined,
    Object? passwordResetCode = _Undefined,
    Object? passwordResetExpiresAt = _Undefined,
    Object? createdAt = _Undefined,
  }) {
    return AppUser(
      id: id is int? ? id : this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      emailVerified: emailVerified ?? this.emailVerified,
      emailVerificationCode: emailVerificationCode is String?
          ? emailVerificationCode
          : this.emailVerificationCode,
      emailVerificationExpiresAt: emailVerificationExpiresAt is DateTime?
          ? emailVerificationExpiresAt
          : this.emailVerificationExpiresAt,
      passwordResetCode: passwordResetCode is String?
          ? passwordResetCode
          : this.passwordResetCode,
      passwordResetExpiresAt: passwordResetExpiresAt is DateTime?
          ? passwordResetExpiresAt
          : this.passwordResetExpiresAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
