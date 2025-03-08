import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:shell_uikit/shell_uikit.dart';
import 'package:unified_distributor/src/cli/command_package.dart';
import 'package:unified_distributor/src/cli/command_publish.dart';
import 'package:unified_distributor/src/cli/command_release.dart';
import 'package:unified_distributor/src/cli/command_upgrade.dart';
import 'package:unified_distributor/unified_distributor.dart';

class UnifiedDistributorCommandLineInterface {
  UnifiedDistributorCommandLineInterface(
    String executableName,
    String description, {
    String? packageName,
    String? displayName,
  }) {
    _distributor = UnifiedDistributor(
      packageName ?? executableName,
      displayName ?? executableName,
    );

    _runner = CommandRunner(executableName, description);
    _runner.addCommand(CommandPackage(_distributor));
    _runner.addCommand(CommandPublish(_distributor));
    _runner.addCommand(CommandRelease(_distributor));
    _runner.addCommand(CommandUpgrade(_distributor));
    _runner.argParser
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
  }

  late final UnifiedDistributor _distributor;
  late final CommandRunner _runner;

  String get displayName => _distributor.displayName;
  String get packageName => _distributor.packageName;

  Future<void> run(List<String> args) async {
    ArgResults argResults = _runner.parse(args);
    if (argResults.wasParsed('version')) {
      String? currentVersion = await _distributor.getCurrentVersion();
      if (currentVersion != null) {
        logger.info(currentVersion);
        return;
      }
    }

    if (argResults['version-check']) {
      Spinner spinner = Spinner(text: 'Checking for updates...');
      spinner.start();
      // Check if a newer version of the tool is available
      final result = await _distributor.checkVersion();
      spinner.stop();
      if (result.isNewVersionAvailable) {
        String msg = [
          '🚀 New version of $displayName available! '
                  .brightYellow(bold: true) +
              '${result.currentVersion}'.brightRed() +
              ' → '.brightYellow() +
              '${result.latestVersion}'.brightGreen(bold: true),
          'Update with: '.brightYellow() +
              '"$packageName upgrade"'.cyan(bold: true),
        ].join('\n');
        logger.info(msg);
      } else {
        String msg = [
          '🎉 You are using the latest version '.brightBlack() +
              '(${result.currentVersion})'.brightBlack(bold: true),
        ].join('\n');
        logger.info(msg);
      }
      logger.info('');
    }
    return _runner.runCommand(argResults);
  }
}
