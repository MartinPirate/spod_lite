import 'dart:io';

import 'package:path/path.dart' as p;

/// Find the `*_server/` directory under [cwd] (searching current dir, one
/// level down, and two levels down). A server dir is identified by having
/// a name that ends with `_server` and a `bin/main.dart` inside.
Directory? findServerDir(Directory cwd) {
  if (File(p.join(cwd.path, 'bin', 'main.dart')).existsSync() &&
      p.basename(cwd.path).endsWith('_server')) {
    return cwd;
  }
  for (final e in cwd.listSync()) {
    if (e is! Directory) continue;
    final base = p.basename(e.path);
    if (base.endsWith('_server') &&
        File(p.join(e.path, 'bin', 'main.dart')).existsSync()) {
      return e;
    }
  }
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

/// Returns the sibling `*_flutter/` directory if present.
Directory? findFlutterDir(Directory serverDir) {
  final parent = serverDir.parent;
  for (final e in parent.listSync()) {
    if (e is! Directory) continue;
    final base = p.basename(e.path);
    if (base.endsWith('_flutter') &&
        File(p.join(e.path, 'pubspec.yaml')).existsSync()) {
      return e;
    }
  }
  return null;
}

/// Derives the project name from a `*_server` directory name.
String projectNameFor(Directory serverDir) {
  final base = p.basename(serverDir.path);
  return base.endsWith('_server') ? base.substring(0, base.length - 7) : base;
}

Future<bool> commandExists(String cmd) async {
  try {
    final r = await Process.run('which', [cmd]);
    return r.exitCode == 0;
  } catch (_) {
    return false;
  }
}

/// Run a process, streaming stdout/stderr to the user, returning the exit code.
Future<int> runInherit(
  String executable,
  List<String> args, {
  String? workingDirectory,
}) async {
  final proc = await Process.start(
    executable,
    args,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
  );
  return await proc.exitCode;
}

/// Locate the `serverpod` binary. Falls back to `$HOME/.pub-cache/bin/serverpod`
/// so we still work when `pub-cache/bin` isn't on PATH.
Future<String?> locateServerpodCli() async {
  if (await commandExists('serverpod')) return 'serverpod';
  final home = Platform.environment['HOME'];
  if (home != null) {
    final pubBin = p.join(home, '.pub-cache', 'bin', 'serverpod');
    if (File(pubBin).existsSync()) return pubBin;
  }
  return null;
}

void logStep(String msg) => stdout.writeln('→ $msg');
void logErr(String msg) => stderr.writeln('spod: $msg');
