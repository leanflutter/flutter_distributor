import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';

class CommandRelease extends Command {
  final FlutterDistributor distributor;

  CommandRelease(this.distributor) {
    argParser.addOption('name', valueHelp: '');
  }

  @override
  String get name => 'release';

  @override
  String get description => 'Release the current Flutter application';

  @override
  Future run() async {
    String name = argResults!['name'] ?? '';

    await distributor.release(name);
  }
}
