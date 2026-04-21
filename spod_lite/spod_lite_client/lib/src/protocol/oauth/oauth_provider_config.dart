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

/// Admin-managed OAuth provider credentials. One row per provider
/// (google, github, apple). clientSecret is stored plaintext — access
/// is restricted to admin-scoped endpoints. If you need at-rest
/// encryption, hold the secret in an env var and leave this row blank
/// for that provider; the provider resolves clientSecret from env
/// when the column is null.
abstract class OAuthProviderConfig implements _i1.SerializableModel {
  OAuthProviderConfig._({
    this.id,
    required this.provider,
    required this.clientId,
    this.clientSecret,
    bool? enabled,
    this.createdAt,
    this.updatedAt,
  }) : enabled = enabled ?? true;

  factory OAuthProviderConfig({
    int? id,
    required String provider,
    required String clientId,
    String? clientSecret,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OAuthProviderConfigImpl;

  factory OAuthProviderConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return OAuthProviderConfig(
      id: jsonSerialization['id'] as int?,
      provider: jsonSerialization['provider'] as String,
      clientId: jsonSerialization['clientId'] as String,
      clientSecret: jsonSerialization['clientSecret'] as String?,
      enabled: jsonSerialization['enabled'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String provider;

  String clientId;

  String? clientSecret;

  bool enabled;

  DateTime? createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [OAuthProviderConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OAuthProviderConfig copyWith({
    int? id,
    String? provider,
    String? clientId,
    String? clientSecret,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OAuthProviderConfig',
      if (id != null) 'id': id,
      'provider': provider,
      'clientId': clientId,
      if (clientSecret != null) 'clientSecret': clientSecret,
      'enabled': enabled,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OAuthProviderConfigImpl extends OAuthProviderConfig {
  _OAuthProviderConfigImpl({
    int? id,
    required String provider,
    required String clientId,
    String? clientSecret,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         provider: provider,
         clientId: clientId,
         clientSecret: clientSecret,
         enabled: enabled,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [OAuthProviderConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OAuthProviderConfig copyWith({
    Object? id = _Undefined,
    String? provider,
    String? clientId,
    Object? clientSecret = _Undefined,
    bool? enabled,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return OAuthProviderConfig(
      id: id is int? ? id : this.id,
      provider: provider ?? this.provider,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret is String? ? clientSecret : this.clientSecret,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
