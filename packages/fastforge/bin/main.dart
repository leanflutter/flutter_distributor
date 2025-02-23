import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:fastforge/fastforge.dart';
import 'package:fastforge/src/utils/logger.dart';

import 'command_package.dart';
import 'command_publish.dart';
import 'command_upgrade.dart';

Future<void> main(List<String> args) async {
  Fastforge fastforge = Fastforge();

  final runner = CommandRunner('fastforge', '');
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

  runner.addCommand(CommandPackage(fastforge));
  runner.addCommand(CommandPublish(fastforge));
  runner.addCommand(CommandUpgrade(fastforge));

  ArgResults argResults = runner.parse(args);
  if (argResults.wasParsed('version')) {
    String? currentVersion = await fastforge.getCurrentVersion();
    if (currentVersion != null) {
      logger.info(currentVersion);
      return;
    }
  }

  if (argResults['version-check']) {
    logger.info('Checking version');
    // Check version of fastforge on every run
    if (!await fastforge.checkVersion()) {
      logger.info('Up to date');
    }
  }

  return runner.runCommand(argResults);
}
