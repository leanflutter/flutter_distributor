import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';

class CommandPackage extends Command {
  final FlutterDistributor distributor;

  CommandPackage(this.distributor) {
    argParser.addOption('platform', valueHelp: '');
    argParser.addOption('targets', valueHelp: '');
    argParser.addOption('channel', valueHelp: '');
    argParser.addOption('artifact-name', valueHelp: '');
    argParser.addFlag('skip-clean');
    argParser.addOption('flutter-build-args', valueHelp: 'verbose,obfuscate');
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
    String? channel = argResults?['channel'];
    String? artifactName = argResults?['artifact-name'];
    String? flutterBuildArgs = argResults?['flutter-build-args'];
    bool isSkipClean = argResults?.wasParsed('skip-clean') ?? false;
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

      for (var arg in flutterBuildArgs?.split(",") ?? <String>[]) {
        if (arg.split("=").length == 2) {
          buildArguments.putIfAbsent(
            arg.split("=").first,
            () => arg.split("=").last,
          );
        } else if (arg.split("=").length == 1) {
          buildArguments.putIfAbsent(
            arg.split("=")[0],
            () => true,
          );
        } else {
          buildArguments.putIfAbsent(arg, () => true);
        }
      }
    }

    await distributor.package(
      platform,
      targets,
      channel: channel,
      artifactName: artifactName,
      cleanBeforeBuild: !isSkipClean,
      buildArguments: buildArguments,
    );
  }
}
