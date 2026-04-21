import 'dart:io';

import 'package:args/command_runner.dart';

import '../util.dart';

/// `spod generate` — wrapper around `serverpod generate` that finds your
/// server directory automatically so you can run it from anywhere in the
/// project.
class GenerateCommand extends Command<int> {
  @override
  String get name => 'generate';

  @override
  String get description =>
      'Run `serverpod generate` in the current project\'s server directory.';

  @override
  Future<int> run() async {
    final serverDir = findServerDir(Directory.current);
    if (serverDir == null) {
      logErr('Could not find a `*_server/` directory under '
          '${Directory.current.path}.');
      return 66;
    }
    final serverpod = await locateServerpodCli();
    if (serverpod == null) {
      logErr('`serverpod` not on PATH. '
          'Install with: dart pub global activate serverpod_cli');
      return 69;
    }
    logStep('Running serverpod generate in ${serverDir.path} …');
    return runInherit(serverpod, ['generate'],
        workingDirectory: serverDir.path);
  }
}
