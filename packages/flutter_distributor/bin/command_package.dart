import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';

class CommandPackage extends Command {
  CommandPackage() {
    argParser.addOption('platform', valueHelp: '');
    argParser.addOption('targets', valueHelp: '');
    argParser.addOption('build-target', valueHelp: '');
    argParser.addOption('build-flavor', valueHelp: '');
    argParser.addOption('build-target-platform', valueHelp: '');
    argParser.addOption('build-export-options-plist', valueHelp: '');
  }

  @override
  String get name => 'package';

  @override
  String get description => 'Package the current Flutter application';

  @override
  Future run() async {
    String platform = argResults?['platform'];
    List<String> targets = '${argResults?['targets']}'.split(',');
    Map<String, dynamic> buildArguments = {};

    if (argResults?.options != null) {
      for (var option in argResults!.options) {
        if (!option.startsWith('build-')) continue;
        buildArguments.putIfAbsent(
          option.replaceAll('build-', ''),
          () => argResults?[option],
        );
      }
    }

    FlutterDistributor distributor = FlutterDistributor();
    await distributor.package(
      platform,
      targets,
      buildArguments,
    );
  }
}
