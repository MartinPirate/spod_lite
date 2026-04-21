import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

const _templateRepo = 'https://github.com/MartinPirate/spod_lite.git';
const _templateSubdir = 'spod_lite';
const _placeholder = 'spod_lite';

final _nameRegExp = RegExp(r'^[a-z][a-z0-9_]{0,62}$');

// Binary / generated / vendored files we skip when rewriting contents.
const _binaryExts = {
  '.png', '.jpg', '.jpeg', '.gif', '.webp', '.ico',
  '.ttf', '.otf', '.woff', '.woff2',
  '.zip', '.gz', '.tar',
  '.pdf', '.mp4', '.mov',
};

// Directories to exclude from the template (not useful for a brand-new project).
const _excludeDirs = {'.dart_tool', 'build', '.git'};

class CreateCommand extends Command<int> {
  CreateCommand() {
    argParser
      ..addOption(
        'into',
        abbr: 'i',
        help: 'Parent directory to create the project in. Defaults to cwd.',
      )
      ..addFlag(
        'pub-get',
        defaultsTo: true,
        help: 'Run `dart pub get` in the server after scaffolding.',
      );
  }

  @override
  String get name => 'create';

  @override
  String get description =>
      'Scaffold a new Serverpod Lite project (server + typed client + dashboard).';

  @override
  String get invocation => 'spod create <name>';

  @override
  Future<int> run() async {
    final rest = argResults?.rest ?? const [];
    if (rest.isEmpty) {
      _err('A project name is required.\n\nUsage: $invocation');
      return 64;
    }
    if (rest.length > 1) {
      _err('Only one project name accepted. Got: ${rest.join(", ")}');
      return 64;
    }

    final projectName = rest.first;
    if (!_nameRegExp.hasMatch(projectName)) {
      _err('Invalid project name: "$projectName"\n'
          'Must start with a lowercase letter and contain only '
          'lowercase letters, digits, and underscores (max 63 chars).');
      return 64;
    }
    if (projectName == _placeholder) {
      _err('"$_placeholder" is the template identifier — pick a different name.');
      return 64;
    }

    final parent = Directory(argResults?['into'] ?? Directory.current.path);
    if (!parent.existsSync()) {
      _err('Parent directory does not exist: ${parent.path}');
      return 66;
    }

    final target = Directory(p.join(parent.path, projectName));
    if (target.existsSync()) {
      _err('Target already exists: ${target.path}');
      return 73;
    }

    if (!await _commandExists('git')) {
      _err('`git` is not on PATH. Install git first.');
      return 69;
    }

    // 1. Clone the template repo into a temp directory.
    final tmp = await Directory.systemTemp.createTemp('spod_lite_cli_');
    _log('Cloning template from $_templateRepo …');
    final cloneProc = await Process.run(
      'git',
      ['clone', '--depth=1', '--quiet', _templateRepo, tmp.path],
    );
    if (cloneProc.exitCode != 0) {
      tmp.deleteSync(recursive: true);
      _err('git clone failed:\n${cloneProc.stderr}');
      return 70;
    }

    try {
      final sourceRoot = Directory(p.join(tmp.path, _templateSubdir));
      if (!sourceRoot.existsSync()) {
        _err('Template layout looks wrong — missing $_templateSubdir/ in clone.');
        return 70;
      }

      // 2. Copy source tree to target, skipping excluded dirs.
      target.createSync(recursive: true);
      _log('Copying template into ${target.path} …');
      await _copyTree(sourceRoot, target);

      // 3. Rewrite file contents + rename directories.
      _log('Renaming "$_placeholder" → "$projectName" …');
      await _rewriteTree(target, from: _placeholder, to: projectName);

      // 4. Optional pub get.
      if (argResults?['pub-get'] == true) {
        final serverDir =
            Directory(p.join(target.path, '${projectName}_server'));
        if (serverDir.existsSync()) {
          _log('Running dart pub get in ${p.relative(serverDir.path)} …');
          final pg = await Process.run(
            'dart',
            ['pub', 'get'],
            workingDirectory: serverDir.path,
          );
          if (pg.exitCode != 0) {
            _log('pub get finished with warnings; you can re-run it by hand.');
          }
        }
      }
    } finally {
      try {
        tmp.deleteSync(recursive: true);
      } catch (_) {}
    }

    _printSuccess(projectName, target);
    return 0;
  }

  void _printSuccess(String name, Directory target) {
    final rel = p.relative(target.path);
    stdout.writeln();
    stdout.writeln('✓ Created $name at $rel');
    stdout.writeln();
    stdout.writeln('Next:');
    stdout.writeln('  cd $rel');
    stdout.writeln('  spod up         # start postgres + server + dashboard');
    stdout.writeln();
    stdout.writeln('Or step by step:');
    stdout.writeln('  docker run -d --name $name-pg \\');
    stdout.writeln('    -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=spodlite \\');
    stdout.writeln('    -e POSTGRES_DB=spod_lite -p 5435:5432 postgres:16-alpine');
    stdout.writeln('  cd ${name}_server && serverpod generate && dart bin/main.dart --apply-migrations');
    stdout.writeln();
  }

  Future<void> _copyTree(Directory from, Directory to) async {
    await for (final entity in from.list(recursive: false, followLinks: false)) {
      final name = p.basename(entity.path);
      if (_excludeDirs.contains(name)) continue;
      final destPath = p.join(to.path, name);
      if (entity is Directory) {
        Directory(destPath).createSync();
        await _copyTree(entity, Directory(destPath));
      } else if (entity is File) {
        entity.copySync(destPath);
      }
    }
  }

  /// Rewrites occurrences of [from] → [to] in text file contents, then
  /// renames directories whose basename contains [from] (bottom-up so
  /// paths stay valid during the traversal).
  Future<void> _rewriteTree(
    Directory root, {
    required String from,
    required String to,
  }) async {
    // Collect entities before mutating.
    final files = <File>[];
    final dirs = <Directory>[];
    await for (final e
        in root.list(recursive: true, followLinks: false)) {
      if (e is File) {
        files.add(e);
      } else if (e is Directory) {
        dirs.add(e);
      }
    }

    // 1. File contents.
    for (final f in files) {
      final ext = p.extension(f.path).toLowerCase();
      if (_binaryExts.contains(ext)) continue;
      try {
        final source = f.readAsStringSync();
        if (!source.contains(from)) continue;
        f.writeAsStringSync(source.replaceAll(from, to));
      } on FileSystemException {
        // Skip unreadable (e.g. socket) or binary-detected-too-late files.
      }
    }

    // 2. Rename dirs, deepest first so parent renames don't break children.
    dirs.sort((a, b) => b.path.length.compareTo(a.path.length));
    for (final d in dirs) {
      if (!d.existsSync()) continue;
      final base = p.basename(d.path);
      if (!base.contains(from)) continue;
      final newPath = p.join(d.parent.path, base.replaceAll(from, to));
      d.renameSync(newPath);
    }
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
