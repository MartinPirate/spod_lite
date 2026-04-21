import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// `spod up` — boots Postgres + applies migrations + starts the server,
/// all from inside a scaffolded project directory.
class UpCommand extends Command<int> {
  UpCommand() {
    argParser
      ..addOption(
        'db-port',
        defaultsTo: '5435',
        help: 'Host port to map Postgres to.',
      )
      ..addOption(
        'db-name',
        defaultsTo: 'spod-pg',
        help: 'Docker container name to use for Postgres.',
      )
      ..addFlag(
        'skip-db',
        defaultsTo: false,
        help: 'Do not start a Postgres container (use an existing one).',
      );
  }

  @override
  String get name => 'up';

  @override
  String get description =>
      'Start Postgres + the server from the current scaffolded project.';

  @override
  Future<int> run() async {
    final cwd = Directory.current;
    final serverDir = _findServerDir(cwd);
    if (serverDir == null) {
      _err('Could not find a `*_server/` directory under ${cwd.path}.\n'
          'Run this from inside a project created by `spod create`.');
      return 66;
    }

    if (argResults?['skip-db'] != true) {
      final ok = await _ensurePostgres(
        containerName: argResults?['db-name'] as String,
        port: argResults?['db-port'] as String,
      );
      if (!ok) return 70;
    }

    _log('Starting server (dart bin/main.dart --apply-migrations) …');
    _log('Landing: http://localhost:8090/   Dashboard: http://localhost:8090/app/');
    _log('Press Ctrl-C to stop.\n');

    final server = await Process.start(
      'dart',
      ['bin/main.dart', '--apply-migrations'],
      workingDirectory: serverDir.path,
      mode: ProcessStartMode.inheritStdio,
    );

    // Forward ^C to the child so it shuts down gracefully.
    ProcessSignal.sigint.watch().listen((_) {
      server.kill(ProcessSignal.sigint);
    });

    return await server.exitCode;
  }

  /// Walks up from [cwd] at most two levels looking for a directory whose
  /// name ends with `_server` and contains `bin/main.dart`.
  Directory? _findServerDir(Directory cwd) {
    // If we're already in the server.
    if (File(p.join(cwd.path, 'bin', 'main.dart')).existsSync()) return cwd;

    // Look one level down.
    for (final e in cwd.listSync()) {
      if (e is! Directory) continue;
      final base = p.basename(e.path);
      if (base.endsWith('_server') &&
          File(p.join(e.path, 'bin', 'main.dart')).existsSync()) {
        return e;
      }
    }

    // Look two levels down (e.g. parent/<name>/<name>_server when user
    // is at the repo root that contains the Serverpod workspace).
    for (final e in cwd.listSync()) {
      if (e is! Directory) continue;
      for (final ee in e.listSync()) {
        if (ee is! Directory) continue;
        final base = p.basename(ee.path);
        if (base.endsWith('_server') &&
            File(p.join(ee.path, 'bin', 'main.dart')).existsSync()) {
          return ee;
        }
      }
    }

    return null;
  }

  Future<bool> _ensurePostgres({
    required String containerName,
    required String port,
  }) async {
    final hasDocker = await _commandExists('docker');
    if (!hasDocker) {
      _err('`docker` is not on PATH. Install Docker Desktop or pass --skip-db.');
      return false;
    }

    // Is the container already there?
    final existsProc = await Process.run(
      'docker',
      ['ps', '-a', '--filter', 'name=^$containerName\$', '--format', '{{.Status}}'],
    );
    final status = (existsProc.stdout as String).trim();

    if (status.isEmpty) {
      _log('Creating Postgres container "$containerName" on port $port …');
      final run = await Process.run('docker', [
        'run',
        '-d',
        '--name',
        containerName,
        '-e',
        'POSTGRES_USER=postgres',
        '-e',
        'POSTGRES_PASSWORD=spodlite',
        '-e',
        'POSTGRES_DB=spod_lite',
        '-p',
        '$port:5432',
        'postgres:16-alpine',
      ]);
      if (run.exitCode != 0) {
        _err('docker run failed:\n${run.stderr}');
        return false;
      }
    } else if (status.startsWith('Up')) {
      _log('Postgres container "$containerName" is already running.');
    } else {
      _log('Starting existing Postgres container "$containerName" …');
      final start = await Process.run('docker', ['start', containerName]);
      if (start.exitCode != 0) {
        _err('docker start failed:\n${start.stderr}');
        return false;
      }
    }

    // Wait for healthy.
    for (var i = 0; i < 30; i++) {
      final ping = await Process.run(
        'docker',
        ['exec', containerName, 'pg_isready', '-U', 'postgres'],
      );
      if (ping.exitCode == 0) return true;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    _err('Postgres did not become ready in 30s.');
    return false;
  }

  Future<bool> _commandExists(String cmd) async {
    try {
      final r = await Process.run('which', [cmd]);
      return r.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  void _log(String msg) => stdout.writeln('→ $msg');
  void _err(String msg) => stderr.writeln('spod: $msg');
}
