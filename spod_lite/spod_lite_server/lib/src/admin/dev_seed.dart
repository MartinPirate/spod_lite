import 'dart:convert';
import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:serverpod/serverpod.dart';

import '../collections/field_types.dart';
import '../collections/identifier_safety.dart';
import '../generated/protocol.dart';

const devAdminEmail = 'admin@spodlite.dev';
const devAdminPassword = 'password123';

/// In development mode, insert a known admin + a demo `tasks` collection
/// so the dashboard and demo app have content to interact with on first
/// boot. No-op in staging/prod.
Future<void> seedDevAdminIfMissing(Serverpod pod) async {
  if (pod.runMode != 'development') return;

  final session = await pod.createSession(enableLogging: false);
  try {
    await _seedAdmin(session);
    await _seedTasksCollection(session);
  } finally {
    await session.close();
  }
}

Future<void> _seedAdmin(Session session) async {
  final existing = await AdminUser.db.findFirstRow(
    session,
    where: (u) => u.email.equals(devAdminEmail),
  );
  if (existing != null) {
    stdout.writeln(
        '[dev-seed] admin already present: $devAdminEmail — nothing to do');
    return;
  }

  final hash = BCrypt.hashpw(devAdminPassword, BCrypt.gensalt(logRounds: 12));
  await AdminUser.db.insertRow(
    session,
    AdminUser(email: devAdminEmail, passwordHash: hash),
  );
  stdout.writeln(
      '[dev-seed] created admin: $devAdminEmail / $devAdminPassword');
}

Future<void> _seedTasksCollection(Session session) async {
  const name = 'tasks';
  final existing = await CollectionDef.db.findFirstRow(
    session,
    where: (c) => c.name.equals(name),
  );
  if (existing != null) {
    stdout.writeln('[dev-seed] collection "$name" already present');
    return;
  }

  final specs = [
    _Spec('title', 'text', required: true),
    _Spec('done', 'bool'),
    _Spec('priority', 'number'),
    _Spec('due_at', 'datetime'),
  ];

  await session.db.transaction((tx) async {
    final def = await CollectionDef.db.insertRow(
      session,
      CollectionDef(
        name: name,
        label: 'Tasks',
        listRule: 'authed',
        viewRule: 'authed',
        createRule: 'authed',
        updateRule: 'authed',
        deleteRule: 'authed',
      ),
      transaction: tx,
    );
    for (var i = 0; i < specs.length; i++) {
      final s = specs[i];
      await CollectionField.db.insertRow(
        session,
        CollectionField(
          collectionDefId: def.id!,
          name: s.name,
          fieldType: s.fieldType,
          required: s.required,
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
    await session.db.unsafeExecute(
      'create table ${quoteIdent(tableNameFor(name))} (${columns.join(", ")})',
      transaction: tx,
    );
  });

  final now = DateTime.now().toUtc();
  final samples = [
    {
      'title': 'Ship the first version',
      'done': true,
      'priority': 1,
      'due_at': now.subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'title': 'Record the demo video',
      'done': false,
      'priority': 2,
      'due_at': now.add(const Duration(days: 1)).toIso8601String(),
    },
    {
      'title': 'Draft the Viktor outreach email',
      'done': false,
      'priority': 1,
      'due_at': now.add(const Duration(days: 3)).toIso8601String(),
    },
    {
      'title': 'Write tests for the rules engine',
      'done': false,
      'priority': 3,
      'due_at': now.add(const Duration(days: 7)).toIso8601String(),
    },
    {
      'title': 'Add record-level rules (M3)',
      'done': false,
      'priority': 3,
      'due_at': now.add(const Duration(days: 14)).toIso8601String(),
    },
  ];
  final table = quoteIdent(tableNameFor(name));
  for (final s in samples) {
    await session.db.unsafeQuery(
      'insert into $table ("title","done","priority","due_at") '
      'values (@title,@done,@priority,@due_at)',
      parameters: QueryParameters.named({
        'title': s['title'],
        'done': s['done'],
        'priority': s['priority'],
        'due_at': DateTime.parse(s['due_at'] as String).toUtc(),
      }),
    );
  }
  stdout.writeln(
      '[dev-seed] created "tasks" with ${samples.length} sample rows · rules=authed');
  // Keep jsonEncode referenced so the import stays useful for future seeds.
  // ignore: prefer_const_declarations, unused_local_variable
  final _ = jsonEncode({'note': 'dev seed complete'});
}

class _Spec {
  final String name;
  final String fieldType;
  final bool required;
  const _Spec(this.name, this.fieldType, {this.required = false});
}
