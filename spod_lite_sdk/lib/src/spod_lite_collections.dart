import 'dart:convert';

/// Plain DTO for a collection definition. Mirrors the server's
/// [CollectionDef] without leaking the generated type.
class CollectionInfo {
  final int id;
  final String name;
  final String label;
  final DateTime? createdAt;

  const CollectionInfo({
    required this.id,
    required this.name,
    required this.label,
    this.createdAt,
  });

  factory CollectionInfo.fromRaw(dynamic raw) => CollectionInfo(
        id: raw.id as int,
        name: raw.name as String,
        label: raw.label as String,
        createdAt: raw.createdAt as DateTime?,
      );

  @override
  String toString() => 'CollectionInfo($name)';
}

/// Plain DTO for a field definition on a collection.
class FieldInfo {
  final int id;
  final int collectionDefId;
  final String name;
  final String fieldType;
  final bool required;
  final int fieldOrder;

  const FieldInfo({
    required this.id,
    required this.collectionDefId,
    required this.name,
    required this.fieldType,
    required this.required,
    required this.fieldOrder,
  });

  factory FieldInfo.fromRaw(dynamic raw) => FieldInfo(
        id: raw.id as int,
        collectionDefId: raw.collectionDefId as int,
        name: raw.name as String,
        fieldType: raw.fieldType as String,
        required: raw.required as bool,
        fieldOrder: raw.fieldOrder as int,
      );
}

/// Specification for a field when creating a collection.
class FieldSpec {
  final String name;
  final String type;
  final bool required;

  const FieldSpec({
    required this.name,
    required this.type,
    this.required = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'fieldType': type,
        'required': required,
      };
}

/// Supported field types.
abstract final class FieldType {
  static const text = 'text';
  static const longtext = 'longtext';
  static const number = 'number';
  static const bool$ = 'bool';
  static const datetime = 'datetime';
  static const json = 'json';

  static const all = [text, longtext, number, bool$, datetime, json];
}

/// Access to the Serverpod Lite dynamic-collections API.
///
/// Obtained via `spod.collections`. Provides collection-level management
/// plus a fluent record API: `spod.collections.collection('todo').list()`.
class SpodLiteCollections {
  final dynamic _collectionsEndpoint;
  final dynamic _recordsEndpoint;

  SpodLiteCollections(this._collectionsEndpoint, this._recordsEndpoint);

  // --- Collection management ---

  Future<List<CollectionInfo>> list() async {
    final raw = await _collectionsEndpoint.list() as List;
    return raw.map(CollectionInfo.fromRaw).toList();
  }

  Future<CollectionInfo?> get(String name) async {
    final raw = await _collectionsEndpoint.get(name);
    if (raw == null) return null;
    return CollectionInfo.fromRaw(raw);
  }

  Future<List<FieldInfo>> fields(int collectionDefId) async {
    final raw = await _collectionsEndpoint.fields(collectionDefId) as List;
    return raw.map(FieldInfo.fromRaw).toList();
  }

  Future<CollectionInfo> create({
    required String name,
    required String label,
    required List<FieldSpec> fields,
  }) async {
    final specsJson = jsonEncode(fields.map((f) => f.toJson()).toList());
    final raw = await _collectionsEndpoint.create(name, label, specsJson);
    return CollectionInfo.fromRaw(raw);
  }

  Future<void> delete(String name) async {
    await _collectionsEndpoint.delete(name);
  }

  /// Fluent handle for records inside a named collection.
  CollectionRef collection(String name) =>
      CollectionRef._(_recordsEndpoint, name);
}

/// Scoped record-level API for one collection.
class CollectionRef {
  final dynamic _records;

  /// The collection this ref targets.
  final String name;

  CollectionRef._(this._records, this.name);

  Future<List<Map<String, dynamic>>> list({
    int page = 1,
    int perPage = 50,
  }) async {
    final raw = await _records.list(name, page, perPage) as List;
    return raw
        .map((s) => jsonDecode(s as String) as Map<String, dynamic>)
        .toList();
  }

  Future<int> count() async {
    return await _records.count(name) as int;
  }

  Future<Map<String, dynamic>?> getOne(int id) async {
    final raw = await _records.get(name, id);
    if (raw == null) return null;
    return jsonDecode(raw as String) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final raw = await _records.create(name, jsonEncode(data)) as String;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final raw = await _records.update(name, id, jsonEncode(data)) as String;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> delete(int id) async {
    await _records.delete(name, id);
  }
}
