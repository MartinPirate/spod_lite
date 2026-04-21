import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../util.dart';

/// `spod add <noun> ...` — parent for code-scaffolding subcommands.
class AddCommand extends Command<int> {
  AddCommand() {
    addSubcommand(AddCollectionCommand());
    addSubcommand(AddEndpointCommand());
    addSubcommand(AddAdminCommand());
    addSubcommand(AddOAuthCommand());
  }

  @override
  String get name => 'add';

  @override
  String get description =>
      'Scaffold new primitives into an existing Serverpod Lite project.';
}

/// `spod add endpoint <name>` — scaffolds a bare `*Endpoint` class.
class AddEndpointCommand extends Command<int> {
  AddEndpointCommand() {
    argParser.addFlag(
      'generate',
      defaultsTo: true,
      help: 'Run `serverpod generate` after scaffolding.',
    );
  }

  @override
  String get name => 'endpoint';

  @override
  String get description =>
      'Scaffold a bare Endpoint class (no table, just methods).';

  @override
  String get invocation => 'spod add endpoint <name>';

  static final _nameRe = RegExp(r'^[a-z][a-z0-9_]{0,62}$');

  @override
  Future<int> run() async {
    final rest = argResults?.rest ?? const [];
    if (rest.length != 1) {
      logErr('One endpoint name required.\n\nUsage: $invocation');
      return 64;
    }
    final name = rest.first;
    if (!_nameRe.hasMatch(name)) {
      logErr('Invalid endpoint name: "$name"');
      return 64;
    }

    final serverDir = findServerDir(Directory.current);
    if (serverDir == null) {
      logErr('Could not find a `*_server/` under ${Directory.current.path}.');
      return 66;
    }

    final className = _camelCase(name);
    final path = p.join(
      serverDir.path,
      'lib',
      'src',
      name,
      '${name}_endpoint.dart',
    );
    if (File(path).existsSync()) {
      logErr('Already exists: $path');
      return 73;
    }
    Directory(p.dirname(path)).createSync(recursive: true);
    File(path).writeAsStringSync('''
import 'package:serverpod/serverpod.dart';

/// Scaffolded by `spod add endpoint`. Each public method becomes a typed
/// endpoint call on the generated client after `serverpod generate`.
class ${className}Endpoint extends Endpoint {
  Future<String> hello(Session session) async {
    return 'hello from ${className}Endpoint';
  }
}
''');
    logStep('Wrote ${p.relative(path)}');

    if (argResults?['generate'] == true) {
      final cli = await locateServerpodCli();
      if (cli == null) {
        logErr('`serverpod` not on PATH — skipping generate.');
      } else {
        logStep('Running serverpod generate …');
        await runInherit(cli, ['generate'],
            workingDirectory: serverDir.path);
      }
    }

    stdout.writeln();
    stdout.writeln('✓ Added endpoint "$name"');
    stdout.writeln('  Restart with `spod up` so the new route is served.');
    return 0;
  }

  String _camelCase(String snake) => snake
      .split('_')
      .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
      .join();
}

/// `spod add admin` — insert an admin_user row directly into Postgres so
/// you can seed additional operators from the CLI. Prompts interactively
/// for email + password if not provided as flags.
class AddAdminCommand extends Command<int> {
  AddAdminCommand() {
    argParser
      ..addOption('email', abbr: 'e', help: 'Admin email.')
      ..addOption('password', abbr: 'p', help: 'Admin password.')
      ..addOption(
        'db-container',
        defaultsTo: 'spod-pg',
        help: 'Docker container running Postgres.',
      );
  }

  @override
  String get name => 'admin';

  @override
  String get description => 'Insert a new admin_user row via the Postgres container.';

  @override
  Future<int> run() async {
    var email = argResults?['email'] as String?;
    var password = argResults?['password'] as String?;
    final container = argResults?['db-container'] as String;

    if (email == null || email.isEmpty) {
      stdout.write('Email: ');
      email = stdin.readLineSync()?.trim();
    }
    if (password == null || password.isEmpty) {
      stdout.write('Password (min 8 chars): ');
      stdin.echoMode = false;
      password = stdin.readLineSync();
      stdin.echoMode = true;
      stdout.writeln();
    }
    if (email == null || email.isEmpty) {
      logErr('Email is required.');
      return 64;
    }
    if (password == null || password.length < 8) {
      logErr('Password must be at least 8 characters.');
      return 64;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      logErr('Invalid email address.');
      return 64;
    }

    if (!await commandExists('docker')) {
      logErr('`docker` is not on PATH.');
      return 69;
    }

    // bcrypt via openssl would require a C dep; easier: call dart inline.
    final hash = await _hashWithDart(password);
    if (hash == null) {
      logErr('Could not hash password (is `dart` on PATH?).');
      return 70;
    }

    final normalized = email.trim().toLowerCase();
    final sql =
        "INSERT INTO admin_user (email, password_hash, created_at) "
        "VALUES ('${normalized.replaceAll("'", "''")}', "
        "'${hash.replaceAll("'", "''")}', NOW()) "
        "ON CONFLICT (email) DO NOTHING RETURNING id;";

    logStep('Inserting admin via $container …');
    final result = await Process.run('docker', [
      'exec',
      container,
      'psql',
      '-U',
      'postgres',
      '-d',
      'spod_lite',
      '-t',
      '-c',
      sql,
    ]);
    if (result.exitCode != 0) {
      logErr('psql failed:\n${result.stderr}');
      return 70;
    }
    final out = (result.stdout as String).trim();
    if (out.isEmpty) {
      stdout.writeln('ℹ admin "$normalized" already exists — no change.');
    } else {
      stdout.writeln('✓ admin "$normalized" created (id=$out).');
    }
    return 0;
  }

  /// Shells out to `dart` to hash the password with the same bcrypt
  /// settings the server uses (logRounds 12). Avoids adding bcrypt as a
  /// CLI dependency just for this one command.
  Future<String?> _hashWithDart(String password) async {
    final snippet =
        "import 'package:bcrypt/bcrypt.dart'; void main() { "
        "print(BCrypt.hashpw(String.fromEnvironment('P'), BCrypt.gensalt(logRounds: 12))); }";
    final tmp = File(
        '${Directory.systemTemp.createTempSync('spod_admin_').path}/hash.dart');
    tmp.writeAsStringSync(snippet);
    // Try to find the server dir so bcrypt is resolvable.
    final serverDir = findServerDir(Directory.current);
    if (serverDir == null) return null;
    final scriptPath = p.join(serverDir.path, '.spod_hash.dart');
    File(scriptPath).writeAsStringSync(snippet);
    try {
      final r = await Process.run(
        'dart',
        ['--define=P=$password', 'run', '.spod_hash.dart'],
        workingDirectory: serverDir.path,
      );
      if (r.exitCode != 0) return null;
      final s = (r.stdout as String).trim();
      return s.isEmpty ? null : s.split('\n').last;
    } finally {
      try {
        File(scriptPath).deleteSync();
      } catch (_) {}
      try {
        tmp.parent.deleteSync(recursive: true);
      } catch (_) {}
    }
  }
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

/// `spod add oauth <provider>` — print the setup walkthrough for a
/// provider, and optionally upsert the credentials row via the running
/// Postgres container when --client-id + --client-secret are passed.
class AddOAuthCommand extends Command<int> {
  AddOAuthCommand() {
    argParser
      ..addOption('client-id', help: 'Provider client id.')
      ..addOption('client-secret', help: 'Provider client secret.')
      ..addFlag('disabled',
          defaultsTo: false,
          help: 'Create the row but leave the provider disabled.')
      ..addOption(
        'db-container',
        defaultsTo: 'spod-pg',
        help: 'Docker container running Postgres.',
      );
  }

  @override
  String get name => 'oauth';

  @override
  String get description =>
      'Wire up an OAuth provider: walkthrough, then upsert credentials.';

  @override
  String get invocation =>
      'spod add oauth <provider> [--client-id=... --client-secret=...]';

  static const _known = <String, _ProviderHint>{
    'google': _ProviderHint(
      label: 'Google',
      console: 'https://console.cloud.google.com/apis/credentials',
      clientType: 'OAuth 2.0 Client ID → Web application',
      redirectExample:
          'Local dev: http://localhost:8088/app/ (or your app\'s origin).',
    ),
    'github': _ProviderHint(
      label: 'GitHub',
      console: 'https://github.com/settings/developers',
      clientType: 'OAuth Apps → New OAuth App',
      redirectExample:
          'Use the same origin + path your app receives the callback on.',
    ),
    'apple': _ProviderHint(
      label: 'Apple',
      console: 'https://developer.apple.com/account/resources/identifiers/list/serviceId',
      clientType: 'Services ID with Sign in with Apple enabled',
      redirectExample:
          'Apple requires HTTPS — use a tunnel for local dev (e.g. ngrok).',
    ),
  };

  @override
  Future<int> run() async {
    final rest = argResults?.rest ?? const [];
    if (rest.length != 1) {
      logErr('One provider id required.\n\nUsage: $invocation\n'
          'Known: ${_known.keys.join(", ")}');
      return 64;
    }
    final provider = rest.first.toLowerCase();
    final hint = _known[provider];
    if (hint == null) {
      logErr('Unknown provider "$provider". '
          'Add a class in lib/src/oauth/providers/ and register it first.');
      return 64;
    }

    _printWalkthrough(provider, hint);

    final clientId = argResults?['client-id'] as String?;
    final clientSecret = argResults?['client-secret'] as String?;
    if (clientId == null || clientSecret == null) {
      stdout.writeln();
      stdout.writeln(
          'Pass --client-id and --client-secret once you have them, or');
      stdout.writeln('set them from the dashboard under "OAuth providers".');
      return 0;
    }

    final enabled = !(argResults?['disabled'] as bool);
    final container = argResults?['db-container'] as String;

    if (!await commandExists('docker')) {
      logErr('`docker` is not on PATH — cannot insert credentials.');
      return 69;
    }

    final sql =
        "INSERT INTO oauth_provider_config "
        "(provider, \"clientId\", \"clientSecret\", enabled, \"createdAt\", \"updatedAt\") "
        "VALUES ('${_escape(provider)}', '${_escape(clientId)}', "
        "'${_escape(clientSecret)}', $enabled, NOW(), NOW()) "
        "ON CONFLICT (provider) DO UPDATE SET "
        "\"clientId\" = EXCLUDED.\"clientId\", "
        "\"clientSecret\" = EXCLUDED.\"clientSecret\", "
        "enabled = EXCLUDED.enabled, "
        "\"updatedAt\" = NOW() "
        "RETURNING id;";

    logStep('Upserting $provider config via $container …');
    final result = await Process.run('docker', [
      'exec',
      container,
      'psql',
      '-U',
      'postgres',
      '-d',
      'spod_lite',
      '-t',
      '-c',
      sql,
    ]);
    if (result.exitCode != 0) {
      logErr('psql failed:\n${result.stderr}');
      return 70;
    }
    final idOut = (result.stdout as String).trim();
    stdout.writeln();
    stdout.writeln('✓ Saved $provider credentials (id=$idOut, '
        'enabled=$enabled).');
    stdout.writeln('  Sign-in-with-${hint.label} is now wired up.');
    return 0;
  }

  void _printWalkthrough(String provider, _ProviderHint hint) {
    stdout.writeln('Sign in with ${hint.label} — setup');
    stdout.writeln('─' * 40);
    stdout.writeln();
    stdout.writeln('1. Open ${hint.console}');
    stdout.writeln('2. Create: ${hint.clientType}');
    stdout.writeln('3. Authorised redirect URI:');
    stdout.writeln('     ${hint.redirectExample}');
    stdout.writeln('4. Copy the client id and secret, then either:');
    stdout.writeln('     a) save from the dashboard (/app/#oauth), or');
    stdout.writeln('     b) rerun this command with');
    stdout.writeln(
        '        --client-id=... --client-secret=...');
    stdout.writeln();
    stdout.writeln(
        'Clients/apps pull the enabled provider list from /oauth.listProviders.');
  }

  String _escape(String s) => s.replaceAll("'", "''");
}

class _ProviderHint {
  final String label;
  final String console;
  final String clientType;
  final String redirectExample;
  const _ProviderHint({
    required this.label,
    required this.console,
    required this.clientType,
    required this.redirectExample,
  });
}
