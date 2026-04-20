import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'identifier_safety.dart';
import 'rule_enforcer.dart';

/// Generic CRUD over user-defined collections.
///
/// Records are passed across the wire as JSON strings because Serverpod's
/// type system doesn't allow `Map<String, dynamic>` — the SDK and
/// dashboard handle the string ↔ map conversion so callers never see it.
///
/// All data values flow through positional/named query parameters —
/// never interpolated. Identifiers go through [quoteIdent] after
/// [assertValidIdentifier].
class RecordsEndpoint extends Endpoint {
  // Not gated at the class level — rules are per-collection per-op and we
  // check them inside each method so `public` collections actually are.

  /// Returns a list of records encoded as JSON strings.
  Future<List<String>> list(
    Session session,
    String collectionName,
    int page,
    int perPage,
  ) async {
    assertValidIdentifier(collectionName, kind: 'collection name');
    final cappedPage = page.clamp(1, 100000);
    final cappedPerPage = perPage.clamp(1, 200);
    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.listRule, operation: 'list');

    final table = quoteIdent(tableNameFor(collectionName));
    final offset = (cappedPage - 1) * cappedPerPage;

    final result = await session.db.unsafeQuery(
      'select * from $table order by "id" desc limit $cappedPerPage offset $offset',
    );
    return result
        .map((row) => jsonEncode(_normalize(row.toColumnMap())))
        .toList();
  }

  Future<int> count(Session session, String collectionName) async {
    assertValidIdentifier(collectionName, kind: 'collection name');
    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.listRule, operation: 'list');
    final table = quoteIdent(tableNameFor(collectionName));
    final result =
        await session.db.unsafeQuery('select count(*) from $table');
    return (result.first[0] as int?) ?? 0;
  }

  Future<String?> get(
    Session session,
    String collectionName,
    int id,
  ) async {
    assertValidIdentifier(collectionName, kind: 'collection name');
    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.viewRule, operation: 'view');

    final table = quoteIdent(tableNameFor(collectionName));
    final result = await session.db.unsafeQuery(
      'select * from $table where "id" = @id limit 1',
      parameters: QueryParameters.named({'id': id}),
    );
    if (result.isEmpty) return null;
    return jsonEncode(_normalize(result.first.toColumnMap()));
  }

  Future<String> create(
    Session session,
    String collectionName,
    String dataJson,
  ) async {
    assertValidIdentifier(collectionName, kind: 'collection name');
    final data = _decodeJson(dataJson);
    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.createRule, operation: 'create');
    final fields = await CollectionField.db.find(
      session,
      where: (f) => f.collectionDefId.equals(def.id!),
    );
    final byName = {for (final f in fields) f.name: f};

    for (final f in fields) {
      if (f.required && (!data.containsKey(f.name) || data[f.name] == null)) {
        throw _ValidationException('Missing required field "${f.name}".');
      }
    }

    final cols = <String>[];
    final placeholders = <String>[];
    final params = <String, dynamic>{};
    for (final entry in data.entries) {
      final field = byName[entry.key];
      if (field == null) continue;
      cols.add(quoteIdent(entry.key));
      placeholders.add('@${entry.key}');
      params[entry.key] = _coerce(entry.value, field.fieldType);
    }
    if (cols.isEmpty) {
      throw _ValidationException('No matching fields provided.');
    }

    final table = quoteIdent(tableNameFor(collectionName));
    final result = await session.db.unsafeQuery(
      'insert into $table (${cols.join(", ")}) values '
      '(${placeholders.join(", ")}) returning *',
      parameters: QueryParameters.named(params),
    );
    return jsonEncode(_normalize(result.first.toColumnMap()));
  }

  Future<String> update(
    Session session,
    String collectionName,
    int id,
    String dataJson,
  ) async {
    assertValidIdentifier(collectionName, kind: 'collection name');
    final data = _decodeJson(dataJson);
    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.updateRule, operation: 'update');
    final fields = await CollectionField.db.find(
      session,
      where: (f) => f.collectionDefId.equals(def.id!),
    );
    final byName = {for (final f in fields) f.name: f};

    final setters = <String>[];
    final params = <String, dynamic>{'_id': id};
    for (final entry in data.entries) {
      final field = byName[entry.key];
      if (field == null) continue;
      setters.add('${quoteIdent(entry.key)} = @${entry.key}');
      params[entry.key] = _coerce(entry.value, field.fieldType);
    }
    if (setters.isEmpty) {
      throw _ValidationException('No matching fields provided.');
    }

    final table = quoteIdent(tableNameFor(collectionName));
    final result = await session.db.unsafeQuery(
      'update $table set ${setters.join(", ")} '
      'where "id" = @_id returning *',
      parameters: QueryParameters.named(params),
    );
    if (result.isEmpty) {
      throw _NotFoundException(
          'Record $id not found in "$collectionName".');
    }
    return jsonEncode(_normalize(result.first.toColumnMap()));
  }

  Future<void> delete(
    Session session,
    String collectionName,
    int id,
  ) async {
    assertValidIdentifier(collectionName, kind: 'collection name');
    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.deleteRule, operation: 'delete');

    final table = quoteIdent(tableNameFor(collectionName));
    await session.db.unsafeExecute(
      'delete from $table where "id" = @id',
      parameters: QueryParameters.named({'id': id}),
    );
  }

  Future<CollectionDef> _requireCollection(
      Session session, String name) async {
    final def = await CollectionDef.db.findFirstRow(
      session,
      where: (c) => c.name.equals(name),
    );
    if (def == null) {
      throw _NotFoundException('Collection "$name" does not exist.');
    }
    return def;
  }

  Map<String, dynamic> _decodeJson(String s) {
    try {
      final decoded = jsonDecode(s);
      if (decoded is! Map) {
        throw _ValidationException('Payload must be a JSON object.');
      }
      return Map<String, dynamic>.from(decoded);
    } on FormatException catch (e) {
      throw _ValidationException('Invalid JSON: ${e.message}');
    }
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> row) {
    return row.map((k, v) {
      if (v is DateTime) return MapEntry(k, v.toUtc().toIso8601String());
      return MapEntry(k, v);
    });
  }

  dynamic _coerce(dynamic value, String fieldType) {
    if (value == null) return null;
    switch (fieldType) {
      case 'number':
        if (value is num) return value.toDouble();
        return double.tryParse(value.toString());
      case 'bool':
        if (value is bool) return value;
        final s = value.toString().toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      case 'datetime':
        if (value is DateTime) return value.toUtc();
        return DateTime.tryParse(value.toString())?.toUtc();
      default:
        return value;
    }
  }
}

class _ValidationException implements Exception {
  final String message;
  _ValidationException(this.message);
  @override
  String toString() => message;
}

class _NotFoundException implements Exception {
  final String message;
  _NotFoundException(this.message);
  @override
  String toString() => message;
}
