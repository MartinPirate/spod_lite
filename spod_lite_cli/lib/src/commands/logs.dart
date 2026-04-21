import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';

import '../util.dart';

/// `spod logs` — live-tails Serverpod's session log via `docker exec`.
/// A pragmatic v1: streams the server's stdout through the container we
/// know about. Full request-log viewing lives in the dashboard's Logs tab.
class LogsCommand extends Command<int> {
  LogsCommand() {
    argParser
      ..addOption(
        'db-container',
        defaultsTo: 'spod-pg',
        help: 'Docker container running Postgres.',
      )
      ..addOption(
        'limit',
        abbr: 'n',
        defaultsTo: '50',
        help: 'Initial rows to show before tailing.',
      )
      ..addFlag(
        'follow',
        abbr: 'f',
        defaultsTo: true,
        help: 'Keep polling for new entries.',
      );
  }

  @override
  String get name => 'logs';

  @override
  String get description =>
      'Tail Serverpod\'s session log from Postgres. Press Ctrl-C to stop.';

  @override
  Future<int> run() async {
    final container = argResults?['db-container'] as String;
    final limit = int.tryParse(argResults?['limit'] as String? ?? '') ?? 50;
    final follow = argResults?['follow'] == true;

    if (!await commandExists('docker')) {
      logErr('`docker` is not on PATH.');
      return 69;
    }

    int lastId = 0;

    // Initial snapshot.
    final initial = await _fetch(container, since: 0, limit: limit);
    if (initial == null) return 70;
    for (final row in initial) {
      _print(row);
      lastId = _maxId(lastId, row);
    }

    if (!follow) return 0;

    logStep('Tailing logs (Ctrl-C to stop) …');
    final sub = ProcessSignal.sigint.watch().listen((_) {
      stdout.writeln();
      exit(0);
    });

    try {
      while (true) {
        await Future<void>.delayed(const Duration(seconds: 2));
        final rows = await _fetch(container, since: lastId, limit: 500);
        if (rows == null) continue;
        for (final row in rows) {
          _print(row);
          lastId = _maxId(lastId, row);
        }
      }
    } finally {
      await sub.cancel();
    }
  }

  int _maxId(int current, Map<String, dynamic> row) {
    final id = row['id'] as int? ?? 0;
    return id > current ? id : current;
  }

  Future<List<Map<String, dynamic>>?> _fetch(
    String container, {
    required int since,
    required int limit,
  }) async {
    // Use `psql -A -t -R<sep>` to emit each column on its own line
    // separated by a record terminator that won't appear in the data.
    const sep = r'\x1f';
    const rec = r'\x1e';
    final sql =
        "SELECT id, COALESCE(endpoint,''), COALESCE(method,''), "
        "COALESCE(duration, 0), COALESCE(\"numQueries\", 0), "
        "COALESCE(error, ''), time "
        "FROM serverpod_session_log "
        "WHERE id > $since "
        "ORDER BY id ASC "
        "LIMIT $limit;";
    final proc = await Process.run('docker', [
      'exec',
      container,
      'psql',
      '-U',
      'postgres',
      '-d',
      'spod_lite',
      '-A',
      '-t',
      '-F',
      sep,
      '-R',
      rec,
      '-c',
      sql,
    ]);
    if (proc.exitCode != 0) {
      logErr('psql failed: ${(proc.stderr as String).trim()}');
      return null;
    }
    final raw = (proc.stdout as String).trim();
    if (raw.isEmpty) return [];
    return raw.split('\x1E').where((s) => s.isNotEmpty).map((s) {
      final f = s.split('\x1F');
      return {
        'id': int.tryParse(f[0]) ?? 0,
        'endpoint': f.length > 1 ? f[1] : '',
        'method': f.length > 2 ? f[2] : '',
        'duration': double.tryParse(f.length > 3 ? f[3] : '0') ?? 0,
        'numQueries': int.tryParse(f.length > 4 ? f[4] : '0') ?? 0,
        'error': f.length > 5 ? f[5] : '',
        'time': f.length > 6 ? f[6] : '',
      };
    }).toList();
  }

  void _print(Map<String, dynamic> row) {
    final time = (row['time'] as String).split('.').first;
    final method = (row['method'] as String).padRight(10).substring(0, 10);
    final endpoint = row['endpoint'] as String;
    final duration = (row['duration'] as num).toStringAsFixed(0);
    final queries = row['numQueries'];
    final err = (row['error'] as String).isNotEmpty;
    final tag = err ? '✗' : '·';
    stdout.writeln(
        '$time  $tag  $method  $endpoint  (${duration}ms, ${queries}q)'
        '${err ? '  ERROR: ${row['error']}' : ''}');
  }

  /// Unused — reserved for future structured JSON output.
  // ignore: unused_element
  String _jsonEscape(String s) => jsonEncode(s);
}
