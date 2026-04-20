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

/// A realtime event emitted whenever a record in a user-defined
/// collection is created, updated, or deleted. Delivered via Serverpod's
/// MessageCentral on the `records:<collection>` channel.
abstract class RecordEvent implements _i1.SerializableModel {
  RecordEvent._({
    required this.type,
    required this.collectionName,
    required this.recordId,
    this.recordJson,
    required this.at,
  });

  factory RecordEvent({
    required String type,
    required String collectionName,
    required int recordId,
    String? recordJson,
    required DateTime at,
  }) = _RecordEventImpl;

  factory RecordEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return RecordEvent(
      type: jsonSerialization['type'] as String,
      collectionName: jsonSerialization['collectionName'] as String,
      recordId: jsonSerialization['recordId'] as int,
      recordJson: jsonSerialization['recordJson'] as String?,
      at: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
    );
  }

  String type;

  String collectionName;

  int recordId;

  String? recordJson;

  DateTime at;

  /// Returns a shallow copy of this [RecordEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RecordEvent copyWith({
    String? type,
    String? collectionName,
    int? recordId,
    String? recordJson,
    DateTime? at,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecordEvent',
      'type': type,
      'collectionName': collectionName,
      'recordId': recordId,
      if (recordJson != null) 'recordJson': recordJson,
      'at': at.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecordEventImpl extends RecordEvent {
  _RecordEventImpl({
    required String type,
    required String collectionName,
    required int recordId,
    String? recordJson,
    required DateTime at,
  }) : super._(
         type: type,
         collectionName: collectionName,
         recordId: recordId,
         recordJson: recordJson,
         at: at,
       );

  /// Returns a shallow copy of this [RecordEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RecordEvent copyWith({
    String? type,
    String? collectionName,
    int? recordId,
    Object? recordJson = _Undefined,
    DateTime? at,
  }) {
    return RecordEvent(
      type: type ?? this.type,
      collectionName: collectionName ?? this.collectionName,
      recordId: recordId ?? this.recordId,
      recordJson: recordJson is String? ? recordJson : this.recordJson,
      at: at ?? this.at,
    );
  }
}
