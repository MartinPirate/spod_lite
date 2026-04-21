import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:spod_lite_cli/src/commands/add.dart';
import 'package:spod_lite_cli/src/commands/create.dart';
import 'package:spod_lite_cli/src/commands/deploy.dart';
import 'package:spod_lite_cli/src/commands/generate.dart';
import 'package:spod_lite_cli/src/commands/logs.dart';
import 'package:spod_lite_cli/src/commands/up.dart';
import 'package:spod_lite_cli/src/commands/version.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner<int>(
    'spod',
    'Serverpod Lite — scaffold and run PocketBase-grade Serverpod projects.',
  )
    ..addCommand(CreateCommand())
    ..addCommand(UpCommand())
    ..addCommand(AddCommand())
    ..addCommand(GenerateCommand())
    ..addCommand(DeployCommand())
    ..addCommand(LogsCommand())
    ..addCommand(VersionCommand());

  final code = await runner.run(args) ?? 0;
  exit(code);
}
