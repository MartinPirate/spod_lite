import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../util.dart';

/// `spod deploy` — builds the Flutter dashboard into the server's web/app/
/// directory, then AOT-compiles `bin/main.dart` to a single native binary.
/// The resulting executable can run standalone on a server of your choice.
class DeployCommand extends Command<int> {
  DeployCommand() {
    argParser
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Path for the compiled binary. Defaults to dist/<name>.',
      )
      ..addFlag(
        'skip-dashboard',
        defaultsTo: false,
        help: 'Do not rebuild the Flutter web dashboard.',
      )
      ..addFlag(
        'skip-binary',
        defaultsTo: false,
        help: 'Only build the dashboard; do not AOT-compile the server.',
      );
  }

  @override
  String get name => 'deploy';

  @override
  String get description =>
      'Build the Flutter dashboard + AOT-compile the server to a single binary.';

  @override
  Future<int> run() async {
    final serverDir = findServerDir(Directory.current);
    if (serverDir == null) {
      logErr('Could not find a `*_server/` directory under '
          '${Directory.current.path}.');
      return 66;
    }
    final projectName = projectNameFor(serverDir);

    // 1. Build Flutter web dashboard.
    if (argResults?['skip-dashboard'] != true) {
      final flutterDir = findFlutterDir(serverDir);
      if (flutterDir == null) {
        logErr('No sibling `*_flutter/` directory found. '
            'Pass --skip-dashboard if that is intentional.');
        return 66;
      }
      if (!await commandExists('flutter')) {
        logErr('`flutter` is not on PATH. Install Flutter or pass --skip-dashboard.');
        return 69;
      }
      logStep('Building Flutter web dashboard …');
      final outDir = p.join(serverDir.path, 'web', 'app');
      final code = await runInherit(
        'flutter',
        [
          'build',
          'web',
          '--base-href',
          '/app/',
          '--output',
          p.relative(outDir, from: flutterDir.path),
        ],
        workingDirectory: flutterDir.path,
      );
      if (code != 0) {
        logErr('flutter build web failed (exit $code).');
        return code;
      }
    }

    // 2. AOT-compile the server.
    if (argResults?['skip-binary'] != true) {
      final outArg = argResults?['output'] as String?;
      final outPath = outArg ?? p.join('dist', projectName);
      final outAbs = p.isAbsolute(outPath)
          ? outPath
          : p.join(Directory.current.path, outPath);
      Directory(p.dirname(outAbs)).createSync(recursive: true);

      logStep('Compiling bin/main.dart → $outPath …');
      final code = await runInherit(
        'dart',
        ['compile', 'exe', 'bin/main.dart', '-o', outAbs],
        workingDirectory: serverDir.path,
      );
      if (code != 0) {
        logErr('dart compile exe failed (exit $code).');
        return code;
      }

      stdout.writeln();
      stdout.writeln('✓ Built $outPath');
      stdout.writeln();
      stdout.writeln('To run it standalone:');
      stdout.writeln('  cp -r ${p.relative(serverDir.path)}/web  ./web');
      stdout.writeln('  cp -r ${p.relative(serverDir.path)}/config ./config');
      stdout.writeln('  cp -r ${p.relative(serverDir.path)}/migrations ./migrations');
      stdout.writeln('  ./$outPath --apply-migrations');
      stdout.writeln();
      stdout.writeln('Set SERVERPOD_* env vars or edit config/production.yaml');
      stdout.writeln('before running in production.');
    }

    return 0;
  }
}
