import 'dart:io';

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

  final runner = CommandRunner('flutter_distributor', '');
  runner.argParser
    ..addFlag(
      'version',
      help: 'Reports the version of this tool.',
      negatable: false,
    )
    ..addFlag(
      'version-check',
      help: 'Check for updates when this command runs.',
      defaultsTo: true,
      negatable: true,
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

  if (argResults['version-check']) {
    // Check version of flutter_distributor on every run
    await distributor.checkVersion();
  }

  dynamic result = await runner.runCommand(argResults);
  if (result != null) {
    exit(-1);
  }
  return result;
}
