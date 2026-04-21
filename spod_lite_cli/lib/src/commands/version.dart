import 'package:args/command_runner.dart';

class VersionCommand extends Command<int> {
  @override
  String get name => 'version';

  @override
  String get description => 'Print the CLI version.';

  @override
  Future<int> run() async {
    // ignore: avoid_print
    print('spod 0.1.0');
    return 0;
  }
}
