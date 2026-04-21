import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'identifier_safety.dart';
import 'rule_enforcer.dart';

String _eventChannel(String collectionName) => 'records:$collectionName';

/// Upper bound on rows scanned when a list/count is gated by a
/// row-level rule. Filtering happens in-app, so this is also the cap on
/// how far back list results can reach. Collections with row-level rules
/// that exceed this size need a custom endpoint or SQL translation —
/// call out in docs/rules.md.
const int _rowCheckScanCap = 1000;

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
    await enforceRule(session, def.listRule,
        operation: 'list', collection: collectionName);

    final table = quoteIdent(tableNameFor(collectionName));
    final offset = (cappedPage - 1) * cappedPerPage;

    // Fast path: no per-row evaluation needed — let Postgres paginate.
    if (!needsRowCheck(def.listRule)) {
      final result = await session.db.unsafeQuery(
        'select * from $table order by "id" desc limit $cappedPerPage offset $offset',
      );
      return result
          .map((row) => jsonEncode(_normalize(row.toColumnMap())))
          .toList();
    }

    // Row-level: scan the newest [_rowCheckScanCap] rows, filter, page
    // in memory. Documented caveat — row-level rules are O(N) on list.
    final result = await session.db.unsafeQuery(
      'select * from $table order by "id" desc limit $_rowCheckScanCap',
    );
    final auth = session.authenticated;
    final filtered = <Map<String, dynamic>>[];
    for (final raw in result) {
      final row = _normalize(raw.toColumnMap());
      if (recordAllowed(rule: def.listRule, auth: auth, record: row)) {
        filtered.add(row);
      }
    }
    final start = offset.clamp(0, filtered.length);
    final end = (offset + cappedPerPage).clamp(0, filtered.length);
    return filtered.sublist(start, end).map(jsonEncode).toList();
  }

  Future<int> count(Session session, String collectionName) async {
    assertValidIdentifier(collectionName, kind: 'collection name');
    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.listRule,
        operation: 'list', collection: collectionName);
    final table = quoteIdent(tableNameFor(collectionName));

    if (!needsRowCheck(def.listRule)) {
      final result =
          await session.db.unsafeQuery('select count(*) from $table');
      return (result.first[0] as int?) ?? 0;
    }

    // Row-level count: scan capped window, filter, count.
    final result = await session.db.unsafeQuery(
      'select * from $table order by "id" desc limit $_rowCheckScanCap',
    );
    final auth = session.authenticated;
    var n = 0;
    for (final raw in result) {
      final row = _normalize(raw.toColumnMap());
      if (recordAllowed(rule: def.listRule, auth: auth, record: row)) n++;
    }
    return n;
  }

  Future<String?> get(
    Session session,
    String collectionName,
    int id,
  ) async {
    assertValidIdentifier(collectionName, kind: 'collection name');
    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.viewRule,
        operation: 'view', collection: collectionName);

    final table = quoteIdent(tableNameFor(collectionName));
    final result = await session.db.unsafeQuery(
      'select * from $table where "id" = @id limit 1',
      parameters: QueryParameters.named({'id': id}),
    );
    if (result.isEmpty) return null;
    final row = _normalize(result.first.toColumnMap());

    // Row-level view rule: treat disallowed as not-found so we don't
    // leak existence of records the caller can't see.
    if (needsRowCheck(def.viewRule)) {
      final auth = session.authenticated;
      if (!recordAllowed(rule: def.viewRule, auth: auth, record: row)) {
        auditRuleDenial(
          session,
          operation: 'view',
          collection: collectionName,
          recordId: id,
          rule: def.viewRule,
          reason: 'row-level expression returned false',
        );
        return null;
      }
    }
    return jsonEncode(row);
  }

  Future<String> create(
    Session session,
    String collectionName,
    String dataJson,
  ) async {
    assertValidIdentifier(collectionName, kind: 'collection name');
    final data = _decodeJson(dataJson);
    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.createRule,
        operation: 'create', collection: collectionName);
    final fields = await CollectionField.db.find(
      session,
      where: (f) => f.collectionDefId.equals(def.id!),
    );
    final byName = {for (final f in fields) f.name: f};

    for (final f in fields) {
      if (f.required && (!data.containsKey(f.name) || data[f.name] == null)) {
        throw SpodLiteException(message: 'Missing required field "${f.name}".', code: SpodLiteErrorCode.invalidInput);
      }
    }

    final cols = <String>[];
    final placeholders = <String>[];
    final params = <String, dynamic>{};
    final proposed = <String, dynamic>{};
    for (final entry in data.entries) {
      final field = byName[entry.key];
      if (field == null) continue;
      final coerced = _coerce(entry.value, field.fieldType);
      cols.add(quoteIdent(entry.key));
      placeholders.add('@${entry.key}');
      params[entry.key] = coerced;
      proposed[entry.key] = coerced;
    }
    if (cols.isEmpty) {
      throw SpodLiteException(message: 'No matching fields provided.', code: SpodLiteErrorCode.invalidInput);
    }

    // Row-level create rule: evaluate against the proposed payload
    // before we touch the table. Server-generated columns (id,
    // created_at) aren't present yet; rules shouldn't reference them.
    if (needsRowCheck(def.createRule)) {
      final auth = session.authenticated;
      if (!recordAllowed(rule: def.createRule, auth: auth, record: proposed)) {
        auditRuleDenial(
          session,
          operation: 'create',
          collection: collectionName,
          rule: def.createRule,
          reason: 'row-level expression returned false on proposed payload',
        );
        throw SpodLiteException(
          message: 'Not allowed to create this record.',
          code: auth == null
              ? SpodLiteErrorCode.unauthorized
              : SpodLiteErrorCode.forbidden,
        );
      }
    }

    final table = quoteIdent(tableNameFor(collectionName));
    final result = await session.db.unsafeQuery(
      'insert into $table (${cols.join(", ")}) values '
      '(${placeholders.join(", ")}) returning *',
      parameters: QueryParameters.named(params),
    );
    final row = _normalize(result.first.toColumnMap());
    final json = jsonEncode(row);
    await _emit(session, collectionName, 'created',
        recordId: row['id'] as int?, recordJson: json);
    return json;
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
    await enforceRule(session, def.updateRule,
        operation: 'update', collection: collectionName);
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
      throw SpodLiteException(message: 'No matching fields provided.', code: SpodLiteErrorCode.invalidInput);
    }

    final table = quoteIdent(tableNameFor(collectionName));

    // Row-level update rule: fetch the current row and evaluate the
    // rule against it before we apply the change. If the rule rejects,
    // surface as not-found so we don't leak existence.
    if (needsRowCheck(def.updateRule)) {
      final current = await session.db.unsafeQuery(
        'select * from $table where "id" = @id limit 1',
        parameters: QueryParameters.named({'id': id}),
      );
      if (current.isEmpty) {
        throw SpodLiteException(
          message: 'Record $id not found in "$collectionName".',
          code: SpodLiteErrorCode.notFound,
        );
      }
      final row = _normalize(current.first.toColumnMap());
      final auth = session.authenticated;
      if (!recordAllowed(rule: def.updateRule, auth: auth, record: row)) {
        auditRuleDenial(
          session,
          operation: 'update',
          collection: collectionName,
          recordId: id,
          rule: def.updateRule,
          reason: 'row-level expression returned false on current row',
        );
        throw SpodLiteException(
          message: 'Record $id not found in "$collectionName".',
          code: SpodLiteErrorCode.notFound,
        );
      }
    }

    final result = await session.db.unsafeQuery(
      'update $table set ${setters.join(", ")} '
      'where "id" = @_id returning *',
      parameters: QueryParameters.named(params),
    );
    if (result.isEmpty) {
      throw SpodLiteException(message:
          'Record $id not found in "$collectionName".', code: SpodLiteErrorCode.notFound);
    }
    final row = _normalize(result.first.toColumnMap());
    final json = jsonEncode(row);
    await _emit(session, collectionName, 'updated',
        recordId: id, recordJson: json);
    return json;
  }

  Future<void> delete(
    Session session,
    String collectionName,
    int id,
  ) async {
    assertValidIdentifier(collectionName, kind: 'collection name');
    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.deleteRule,
        operation: 'delete', collection: collectionName);

    final table = quoteIdent(tableNameFor(collectionName));

    if (needsRowCheck(def.deleteRule)) {
      final current = await session.db.unsafeQuery(
        'select * from $table where "id" = @id limit 1',
        parameters: QueryParameters.named({'id': id}),
      );
      if (current.isEmpty) return; // already absent — idempotent delete
      final row = _normalize(current.first.toColumnMap());
      final auth = session.authenticated;
      if (!recordAllowed(rule: def.deleteRule, auth: auth, record: row)) {
        auditRuleDenial(
          session,
          operation: 'delete',
          collection: collectionName,
          recordId: id,
          rule: def.deleteRule,
          reason: 'row-level expression returned false on current row',
        );
        throw SpodLiteException(
          message: 'Record $id not found in "$collectionName".',
          code: SpodLiteErrorCode.notFound,
        );
      }
    }

    await session.db.unsafeExecute(
      'delete from $table where "id" = @id',
      parameters: QueryParameters.named({'id': id}),
    );
    await _emit(session, collectionName, 'deleted', recordId: id);
  }

  /// Live stream of record events for a collection. Enforces the same
  /// rule as `list`. For row-level rules, `created`/`updated` events are
  /// filtered against the current state; `deleted` events carry only an
  /// id (no row to evaluate) and are delivered unconditionally — UIs
  /// need the signal to remove stale items they may have already
  /// surfaced. This trades a small existence leak for live-sync
  /// usability; see docs/rules.md.
  Stream<RecordEvent> watch(
    Session session,
    String collectionName,
  ) async* {
    assertValidIdentifier(collectionName, kind: 'collection name');
    final def = await _requireCollection(session, collectionName);
    await enforceRule(session, def.listRule,
        operation: 'watch', collection: collectionName);

    final stream = session.messages
        .createStream<RecordEvent>(_eventChannel(collectionName));

    if (!needsRowCheck(def.listRule)) {
      yield* stream;
      return;
    }

    final auth = session.authenticated;
    await for (final event in stream) {
      if (event.type == 'deleted' || event.recordJson == null) {
        yield event;
        continue;
      }
      try {
        final row = Map<String, dynamic>.from(jsonDecode(event.recordJson!) as Map);
        if (recordAllowed(rule: def.listRule, auth: auth, record: row)) {
          yield event;
        }
      } on FormatException {
        // Malformed payload from producer — don't crash the stream;
        // drop the event so we never surface an un-evaluated row.
      }
    }
  }

  Future<void> _emit(
    Session session,
    String collectionName,
    String type, {
    required int? recordId,
    String? recordJson,
  }) async {
    if (recordId == null) return;
    await session.messages.postMessage(
      _eventChannel(collectionName),
      RecordEvent(
        type: type,
        collectionName: collectionName,
        recordId: recordId,
        recordJson: recordJson,
        at: DateTime.now().toUtc(),
      ),
      // Broadcast across cluster nodes when Redis is enabled. Silently
      // local-only when it isn't (single-node dev).
      global: true,
    );
  }

  Future<CollectionDef> _requireCollection(
      Session session, String name) async {
    final def = await CollectionDef.db.findFirstRow(
      session,
      where: (c) => c.name.equals(name),
    );
    if (def == null) {
      throw SpodLiteException(message: 'Collection "$name" does not exist.', code: SpodLiteErrorCode.notFound);
    }
    return def;
  }

  Map<String, dynamic> _decodeJson(String s) {
    try {
      final decoded = jsonDecode(s);
      if (decoded is! Map) {
        throw SpodLiteException(message: 'Payload must be a JSON object.', code: SpodLiteErrorCode.invalidInput);
      }
      return Map<String, dynamic>.from(decoded);
    } on FormatException catch (e) {
      throw SpodLiteException(message: 'Invalid JSON: ${e.message}', code: SpodLiteErrorCode.invalidInput);
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

