import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';
import 'package:flutter_distributor/src/utils/logger.dart';

import 'command_package.dart';
import 'command_publish.dart';
import 'command_release.dart';
import 'command_upgrade.dart';

Future<void> main(List<String> args) async {
  FlutterDistributor distributor = FlutterDistributor();

  // Check version of flutter_distributor on every run
  await distributor.checkVersion();

  final runner = CommandRunner('flutter_distributor', '');

  runner.argParser.addFlag(
    'version',
    negatable: false,
    help: 'Reports the version of this tool.',
  );

  runner.addCommand(CommandPackage(distributor));
  runner.addCommand(CommandPublish(distributor));
  runner.addCommand(CommandRelease(distributor));
  runner.addCommand(CommandUpgrade(distributor));

  ArgResults argResults = runner.parse(args);
  if (argResults.wasParsed('version')) {
    String? currentVersion = await distributor.getCurrentVersion();
    if (currentVersion != null) {
      logger.info(currentVersion);
      return;
    }
  }

  return runner.runCommand(argResults);
}
