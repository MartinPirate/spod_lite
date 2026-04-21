import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../util.dart';

/// `spod add <noun> ...` — parent for code-scaffolding subcommands.
class AddCommand extends Command<int> {
  AddCommand() {
    addSubcommand(AddCollectionCommand());
  }

  @override
  String get name => 'add';

  @override
  String get description =>
      'Scaffold new primitives into an existing Serverpod Lite project.';
}

class AddCollectionCommand extends Command<int> {
  AddCollectionCommand() {
    argParser
      ..addMultiOption(
        'field',
        abbr: 'f',
        help:
            'Field spec — format: name:type[:required]. Types: text, longtext, '
            'number, bool, datetime. May be repeated.',
      )
      ..addFlag(
        'generate',
        defaultsTo: true,
        help: 'Run `serverpod generate` after writing the spy file.',
      )
      ..addFlag(
        'migration',
        defaultsTo: true,
        help: 'Run `serverpod create-migration` too.',
      );
  }

  @override
  String get name => 'collection';

  @override
  String get description =>
      'Add a static (spy.yaml-backed) collection to the current project.';

  @override
  String get invocation => 'spod add collection <name> [-f name:type ...]';

  static final _nameRe = RegExp(r'^[a-z][a-z0-9_]{0,62}$');

  static const _typeMap = <String, String>{
    'text': 'String',
    'longtext': 'String',
    'number': 'double',
    'bool': 'bool',
    'datetime': 'DateTime?',
  };

  @override
  Future<int> run() async {
    final rest = argResults?.rest ?? const [];
    if (rest.isEmpty) {
      logErr('A collection name is required.\n\nUsage: $invocation');
      return 64;
    }
    if (rest.length > 1) {
      logErr('Only one collection name accepted. Got: ${rest.join(", ")}');
      return 64;
    }
    final collectionName = rest.first;
    if (!_nameRe.hasMatch(collectionName)) {
      logErr('Invalid collection name: "$collectionName"\n'
          'Must start with a lowercase letter, contain only '
          'lowercase letters, digits, and underscores (max 63 chars).');
      return 64;
    }

    final cwd = Directory.current;
    final serverDir = findServerDir(cwd);
    if (serverDir == null) {
      logErr('Could not find a `*_server/` directory under ${cwd.path}.\n'
          'Run this from inside a project created by `spod create`.');
      return 66;
    }

    final fields = _parseFields(argResults?['field'] as List<String>);
    if (fields == null) return 64;

    final spyPath = p.join(
      serverDir.path,
      'lib',
      'src',
      collectionName,
      '$collectionName.spy.yaml',
    );
    final endpointPath = p.join(
      serverDir.path,
      'lib',
      'src',
      collectionName,
      '${collectionName}_endpoint.dart',
    );
    if (File(spyPath).existsSync()) {
      logErr('Already exists: $spyPath');
      return 73;
    }

    Directory(p.dirname(spyPath)).createSync(recursive: true);
    File(spyPath).writeAsStringSync(_renderSpy(collectionName, fields));
    File(endpointPath).writeAsStringSync(
        _renderEndpoint(collectionName, _camelCaseClass(collectionName)));
    logStep('Wrote ${p.relative(spyPath)}');
    logStep('Wrote ${p.relative(endpointPath)}');

    if (argResults?['generate'] == true) {
      final serverpod = await locateServerpodCli();
      if (serverpod == null) {
        logErr('`serverpod` not on PATH — skipping generate. '
            'Install with: dart pub global activate serverpod_cli');
      } else {
        logStep('Running serverpod generate …');
        final code = await runInherit(serverpod, ['generate'],
            workingDirectory: serverDir.path);
        if (code != 0) {
          logErr('serverpod generate failed (exit $code).');
          return code;
        }

        if (argResults?['migration'] == true) {
          logStep('Running serverpod create-migration …');
          final mcode = await runInherit(
              serverpod, ['create-migration'],
              workingDirectory: serverDir.path);
          if (mcode != 0) {
            logErr('serverpod create-migration failed (exit $mcode).');
            return mcode;
          }
        }
      }
    }

    _printNext(collectionName);
    return 0;
  }

  void _printNext(String collection) {
    stdout.writeln();
    stdout.writeln('✓ Added "$collection"');
    stdout.writeln();
    stdout.writeln('Next:');
    stdout.writeln('  Restart the server with --apply-migrations so the new');
    stdout.writeln('  table goes live:');
    stdout.writeln();
    stdout.writeln('  spod up');
    stdout.writeln();
  }

  List<_Field>? _parseFields(List<String> raw) {
    final fields = <_Field>[];
    for (final spec in raw) {
      final parts = spec.split(':');
      if (parts.length < 2 || parts.length > 3) {
        logErr('Bad --field "$spec". Use name:type or name:type:required.');
        return null;
      }
      final name = parts[0];
      final type = parts[1];
      final required = parts.length == 3 && parts[2] == 'required';
      if (!_nameRe.hasMatch(name)) {
        logErr('Bad field name "$name".');
        return null;
      }
      if (!_typeMap.containsKey(type)) {
        logErr('Unknown field type "$type". '
            'Allowed: ${_typeMap.keys.join(", ")}.');
        return null;
      }
      fields.add(_Field(name: name, type: type, required: required));
    }
    return fields;
  }

  String _renderSpy(String name, List<_Field> fields) {
    final className = _camelCaseClass(name);
    final buf = StringBuffer();
    buf.writeln('### A $name record. Scaffolded by `spod add collection`.');
    buf.writeln('class: $className');
    buf.writeln('table: $name');
    buf.writeln();
    buf.writeln('fields:');
    if (fields.isEmpty) {
      buf.writeln('  # Add fields here, then re-run `serverpod generate`.');
      buf.writeln('  title: String');
    } else {
      for (final f in fields) {
        final dartType = _typeMap[f.type]!;
        final nullable = dartType.endsWith('?');
        final suffix = f.required && !nullable ? '' : (nullable ? '' : '?');
        buf.writeln('  ${f.name}: $dartType$suffix');
      }
    }
    buf.writeln('  createdAt: DateTime?, defaultPersist=now');
    return buf.toString();
  }

  String _renderEndpoint(String name, String className) {
    return '''
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Scaffolded by `spod add collection`. Add methods as you need — each
/// public method becomes a typed endpoint after `serverpod generate`.
class ${className}sEndpoint extends Endpoint {
  Future<List<$className>> list(Session session) async {
    return $className.db.find(
      session,
      orderBy: (r) => r.createdAt,
      orderDescending: true,
    );
  }

  Future<$className> create(Session session, $className record) async {
    return $className.db.insertRow(session, record);
  }

  Future<void> delete(Session session, int id) async {
    await $className.db.deleteWhere(session, where: (r) => r.id.equals(id));
  }
}
''';
  }

  /// `blog_post` → `BlogPost`.
  String _camelCaseClass(String snake) {
    return snake
        .split('_')
        .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
        .join();
  }
}

class _Field {
  final String name;
  final String type;
  final bool required;
  const _Field({
    required this.name,
    required this.type,
    required this.required,
  });
}
