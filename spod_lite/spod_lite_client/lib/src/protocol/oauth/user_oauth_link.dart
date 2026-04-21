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

/// Links an `AppUser` to an external OAuth identity. Lets the same
/// account be reached via multiple providers (Google + email, etc).
abstract class UserOAuthLink implements _i1.SerializableModel {
  UserOAuthLink._({
    this.id,
    required this.appUserId,
    required this.provider,
    required this.providerUserId,
    required this.emailAtLink,
    this.linkedAt,
  });

  factory UserOAuthLink({
    int? id,
    required int appUserId,
    required String provider,
    required String providerUserId,
    required String emailAtLink,
    DateTime? linkedAt,
  }) = _UserOAuthLinkImpl;

  factory UserOAuthLink.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserOAuthLink(
      id: jsonSerialization['id'] as int?,
      appUserId: jsonSerialization['appUserId'] as int,
      provider: jsonSerialization['provider'] as String,
      providerUserId: jsonSerialization['providerUserId'] as String,
      emailAtLink: jsonSerialization['emailAtLink'] as String,
      linkedAt: jsonSerialization['linkedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['linkedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int appUserId;

  String provider;

  String providerUserId;

  String emailAtLink;

  DateTime? linkedAt;

  /// Returns a shallow copy of this [UserOAuthLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserOAuthLink copyWith({
    int? id,
    int? appUserId,
    String? provider,
    String? providerUserId,
    String? emailAtLink,
    DateTime? linkedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserOAuthLink',
      if (id != null) 'id': id,
      'appUserId': appUserId,
      'provider': provider,
      'providerUserId': providerUserId,
      'emailAtLink': emailAtLink,
      if (linkedAt != null) 'linkedAt': linkedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserOAuthLinkImpl extends UserOAuthLink {
  _UserOAuthLinkImpl({
    int? id,
    required int appUserId,
    required String provider,
    required String providerUserId,
    required String emailAtLink,
    DateTime? linkedAt,
  }) : super._(
         id: id,
         appUserId: appUserId,
         provider: provider,
         providerUserId: providerUserId,
         emailAtLink: emailAtLink,
         linkedAt: linkedAt,
       );

  /// Returns a shallow copy of this [UserOAuthLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserOAuthLink copyWith({
    Object? id = _Undefined,
    int? appUserId,
    String? provider,
    String? providerUserId,
    String? emailAtLink,
    Object? linkedAt = _Undefined,
  }) {
    return UserOAuthLink(
      id: id is int? ? id : this.id,
      appUserId: appUserId ?? this.appUserId,
      provider: provider ?? this.provider,
      providerUserId: providerUserId ?? this.providerUserId,
      emailAtLink: emailAtLink ?? this.emailAtLink,
      linkedAt: linkedAt is DateTime? ? linkedAt : this.linkedAt,
    );
  }
}
