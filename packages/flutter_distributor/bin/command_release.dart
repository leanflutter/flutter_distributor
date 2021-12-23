import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';

class CommandRelease extends Command {
  CommandRelease() {
    argParser.addOption('type', valueHelp: '');
  }

  @override
  String get name => 'release';

  @override
  String get description => 'Release the current Flutter application';

  @override
  Future run() async {
    String type = argResults?['type'];

    FlutterDistributor distributor = FlutterDistributor();
    await distributor.release(type);
  }
}
