import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';

class CommandPackage extends Command {
  final FlutterDistributor distributor;

  CommandPackage(this.distributor) {
    argParser.addOption('platform', valueHelp: '');
    argParser.addOption('targets', valueHelp: '');
    argParser.addOption('build-target', valueHelp: 'path');
    argParser.addOption('build-flavor', valueHelp: '');
    argParser.addOption('build-target-platform', valueHelp: '');
    argParser.addOption('build-export-options-plist', valueHelp: '');
    argParser.addMultiOption('build-dart-define', valueHelp: 'foo=bar');
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
        dynamic value = argResults?[option];

        if (value is List) {
          value = Map.fromIterable(
            value,
            key: (e) => e.split('=')[0],
            value: (e) => e.split('=')[1],
          );
        }

        buildArguments.putIfAbsent(
          option.replaceAll('build-', ''),
          () => value,
        );
      }
    }

    await distributor.package(
      platform,
      targets,
      buildArguments,
    );
  }
}
