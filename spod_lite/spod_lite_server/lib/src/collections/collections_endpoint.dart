import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import '../admin/admin_authentication_handler.dart';
import '../generated/protocol.dart';
import 'field_types.dart';
import 'identifier_safety.dart';
import 'rule_enforcer.dart';

/// Dashboard-side API for creating and listing user-defined collections.
///
/// Each collection is backed by a dynamically-created `collection_<name>`
/// table in Postgres. Definitions live in `collection_def` and
/// `collection_field`. All DDL goes through [quoteIdent] after
/// [assertValidIdentifier] — there is no other path.
class CollectionsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {adminScope};

  Future<List<CollectionDef>> list(Session session) async {
    return CollectionDef.db.find(
      session,
      orderBy: (c) => c.createdAt,
    );
  }

  Future<CollectionDef?> get(Session session, String name) async {
    assertValidIdentifier(name, kind: 'collection name');
    return CollectionDef.db.findFirstRow(
      session,
      where: (c) => c.name.equals(name),
    );
  }

  Future<List<CollectionField>> fields(
      Session session, int collectionDefId) async {
    return CollectionField.db.find(
      session,
      where: (f) => f.collectionDefId.equals(collectionDefId),
      orderBy: (f) => f.fieldOrder,
    );
  }

  /// Create a collection: inserts definition + field rows and runs
  /// `CREATE TABLE` atomically. If any step fails the whole thing
  /// rolls back so we don't orphan a definition without a table (or
  /// vice versa).
  /// `specsJson` must decode to a JSON array of `{name, fieldType, required}`
  /// objects. JSON on the wire keeps this endpoint free of generated-type
  /// dependencies so any Serverpod client can call it.
  Future<CollectionDef> create(
    Session session,
    String name,
    String label,
    String specsJson,
  ) async {
    assertValidIdentifier(name, kind: 'collection name');
    final specs = _decodeSpecs(specsJson);
    for (final s in specs) {
      assertValidIdentifier(s.name, kind: 'field name');
      if (!isKnownFieldType(s.fieldType)) {
        throw InvalidIdentifierException(
            'Unknown field type "${s.fieldType}". Allowed: ${knownFieldTypes.join(", ")}.');
      }
    }
    if (specs.isEmpty) {
      throw InvalidIdentifierException(
          'A collection must have at least one field.');
    }
    // Guard against duplicate field names inside a single request.
    final seen = <String>{};
    for (final s in specs) {
      if (!seen.add(s.name)) {
        throw InvalidIdentifierException(
            'Duplicate field name "${s.name}" in request.');
      }
    }
    // Reject clash with the built-in columns we always add.
    for (final s in specs) {
      if (s.name == 'id' || s.name == 'created_at') {
        throw InvalidIdentifierException(
            '"${s.name}" is a reserved built-in column.');
      }
    }

    final existing = await CollectionDef.db.findFirstRow(
      session,
      where: (c) => c.name.equals(name),
    );
    if (existing != null) {
      throw InvalidIdentifierException(
          'Collection "$name" already exists.');
    }

    return session.db.transaction<CollectionDef>((tx) async {
      final def = await CollectionDef.db.insertRow(
        session,
        CollectionDef(name: name, label: label),
        transaction: tx,
      );

      for (var i = 0; i < specs.length; i++) {
        await CollectionField.db.insertRow(
          session,
          CollectionField(
            collectionDefId: def.id!,
            name: specs[i].name,
            fieldType: specs[i].fieldType,
            required: specs[i].required,
            fieldOrder: i,
          ),
          transaction: tx,
        );
      }

      final columns = <String>[
        '"id" bigserial primary key',
        '"created_at" timestamp with time zone not null default now()',
      ];
      for (final s in specs) {
        columns.add(
          '${quoteIdent(s.name)} ${sqlTypeFor(s.fieldType)}'
          '${s.required ? " not null" : ""}',
        );
      }

      final table = quoteIdent(tableNameFor(name));
      await session.db.unsafeExecute(
        'create table $table (${columns.join(", ")})',
        transaction: tx,
      );

      session.log(
        '[collections] created "$name" with ${specs.length} fields',
      );
      return def;
    });
  }

  /// Delete a collection: drops the dynamic table first (if present),
  /// then the definition — which cascades to its fields.
  Future<void> delete(Session session, String name) async {
    assertValidIdentifier(name, kind: 'collection name');

    await session.db.transaction((tx) async {
      final table = quoteIdent(tableNameFor(name));
      await session.db.unsafeExecute(
        'drop table if exists $table',
        transaction: tx,
      );

      // Cascade via explicit child delete, since we don't have an ON DELETE
      // CASCADE at the schema level yet.
      final def = await CollectionDef.db.findFirstRow(
        session,
        where: (c) => c.name.equals(name),
        transaction: tx,
      );
      if (def != null) {
        await CollectionField.db.deleteWhere(
          session,
          where: (f) => f.collectionDefId.equals(def.id!),
          transaction: tx,
        );
        await CollectionDef.db.deleteWhere(
          session,
          where: (c) => c.name.equals(name),
          transaction: tx,
        );
      }
      session.log('[collections] dropped "$name"');
    });
  }

  /// Update the 5 per-op rules on an existing collection. Accepts any
  /// subset; omitted keys stay unchanged. Allowed values: `public`,
  /// `authed`, `admin`.
  Future<CollectionDef> updateRules(
    Session session,
    String name,
    String rulesJson,
  ) async {
    assertValidIdentifier(name, kind: 'collection name');
    final rules = _decodeRules(rulesJson);

    final def = await CollectionDef.db.findFirstRow(
      session,
      where: (c) => c.name.equals(name),
    );
    if (def == null) {
      throw InvalidIdentifierException(
          'Collection "$name" does not exist.');
    }

    final updated = def.copyWith(
      listRule: rules['listRule'] ?? def.listRule,
      viewRule: rules['viewRule'] ?? def.viewRule,
      createRule: rules['createRule'] ?? def.createRule,
      updateRule: rules['updateRule'] ?? def.updateRule,
      deleteRule: rules['deleteRule'] ?? def.deleteRule,
    );
    return CollectionDef.db.updateRow(session, updated);
  }

  Map<String, String> _decodeRules(String json) {
    final decoded = jsonDecode(json);
    if (decoded is! Map) {
      throw InvalidIdentifierException(
          'Rules must be a JSON object.');
    }
    const allowedKeys = {
      'listRule', 'viewRule', 'createRule', 'updateRule', 'deleteRule'
    };
    final result = <String, String>{};
    for (final entry in decoded.entries) {
      final key = entry.key.toString();
      if (!allowedKeys.contains(key)) continue;
      final value = entry.value.toString();
      if (!ruleModes.contains(value)) {
        throw InvalidIdentifierException(
            'Rule value "$value" is invalid. Allowed: ${ruleModes.join(", ")}.');
      }
      result[key] = value;
    }
    return result;
  }

  List<_FieldSpec> _decodeSpecs(String json) {
    final decoded = jsonDecode(json);
    if (decoded is! List) {
      throw InvalidIdentifierException(
          'Field specs must be a JSON array.');
    }
    return decoded.map((item) {
      if (item is! Map) {
        throw InvalidIdentifierException(
            'Each field spec must be a JSON object.');
      }
      return _FieldSpec(
        name: (item['name'] ?? '').toString(),
        fieldType: (item['fieldType'] ?? '').toString(),
        required: item['required'] == true,
      );
    }).toList();
  }
}

class _FieldSpec {
  final String name;
  final String fieldType;
  final bool required;
  _FieldSpec({
    required this.name,
    required this.fieldType,
    required this.required,
  });
}
