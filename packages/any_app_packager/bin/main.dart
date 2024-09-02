import 'dart:io';

import 'package:any_app_packager/src/any_app_packager.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';

/// Package an application bundle for a specific platform and target
///
/// This command wrapper defines, parses and transforms all passed arguments,
/// so that they may be passed to `flutter_distributor`. The distributor will
/// then build an application bundle using `flutter_app_packager`.
class PackageCommand extends Command {
  PackageCommand(this.appPackager) {
    argParser.addOption(
      'platform',
      valueHelp: [
        'android',
        'ios',
        'linux',
        'macos',
        'windows',
        'web',
      ].join(','),
      help: 'The platform to package the application for',
    );

    argParser.addOption(
      'targets',
      aliases: ['target'],
      valueHelp: [
        'apk',
        'aab',
        'appimage',
        'deb',
        'dmg',
        'exe',
        'ipa',
        'msix',
        'pkg',
        'rpm',
        'zip',
      ].join(','),
      help: 'Comma separated list of bundle types to build.',
    );

    argParser.addOption('channel', valueHelp: '');
    argParser.addOption('artifact-name', valueHelp: '');

    argParser.addFlag(
      'skip-clean',
      help: 'Whether or not to skip \'flutter clean\' before packaging.',
    );

    argParser.addOption(
      'flutter-build-args',
      valueHelp: 'verbose,obfuscate',
      help: 'Arguments to pass directly to flutter build',
    );

    argParser.addOption(
      'build-target',
      valueHelp: 'path',
      help: 'The --target argument passed to \'flutter build\'',
    );

    argParser.addOption(
      'build-flavor',
      valueHelp: '',
      help: 'The --flavor argument passed to \'flutter build\'',
    );

    argParser.addOption(
      'build-target-platform',
      valueHelp: '',
      help: 'The --target-platform argument passed to \'flutter build\'',
    );

    argParser.addOption(
      'build-export-options-plist',
      valueHelp: '',
      help: 'The --export-options-plist argument passed \'flutter build\'',
    );

    argParser.addMultiOption(
      'build-dart-define',
      valueHelp: 'foo=bar',
      help: [
        'The --dart-define argument(s) passed to \'flutter build\'',
        'You may add multiple \'--build-dart-define key=value\' pairs',
      ].join('\n'),
    );
  }

  final AnyAppPackager appPackager;

  @override
  String get name => 'package';

  @override
  String get description => [
        'Package the current Flutter application',
        '',
        'Options named --build-* are passed to \'flutter build\' as is',
        'Please consult the \'flutter build\' CLI help for more informations.',
      ].join('\n');

  @override
  Future run() async {
    final String? platform = argResults?['platform'];
    final List<String> targets = '${argResults?['targets'] ?? ''}'
        .split(',')
        .where((e) => e.isNotEmpty)
        .toList();
    final String? channel = argResults?['channel'];
    final String? artifactName = argResults?['artifact-name'];
    final String? flutterBuildArgs = argResults?['flutter-build-args'];
    final bool isSkipClean = argResults?.wasParsed('skip-clean') ?? false;
    final Map<String, dynamic> buildArguments =
        _generateBuildArgs(flutterBuildArgs);

    // At least `platform` and one `targets` is required for flutter build
    if (platform == null) {
      print('\nThe \'platform\' options is mandatory!');
      exit(1);
    }

    if (targets.isEmpty) {
      print('\nAt least one \'target\' must be specified!');
      exit(1);
    }

    return appPackager.package(
      platform,
      targets,
      channel: channel,
      artifactName: artifactName,
      cleanBeforeBuild: !isSkipClean,
      buildArguments: buildArguments,
    );
  }

  Map<String, dynamic> _generateBuildArgs(String? flutterBuildArgs) {
    Map<String, dynamic> buildArguments = {};

    if (argResults?.options == null) return buildArguments;

    for (var option in argResults!.options) {
      if (!option.startsWith('build-')) continue;
      dynamic value = argResults?[option];

      if (value is List) {
        // ignore: prefer_for_elements_to_map_fromiterable
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

    for (var arg in flutterBuildArgs?.split(',') ?? <String>[]) {
      if (arg.split('=').length == 2) {
        buildArguments.putIfAbsent(
          arg.split('=').first,
          () => arg.split('=').last,
        );
      } else if (arg.split('=').length == 1) {
        buildArguments.putIfAbsent(
          arg.split('=')[0],
          () => true,
        );
      } else {
        buildArguments.putIfAbsent(arg, () => true);
      }
    }

    return buildArguments;
  }
}

Future<void> main(List<String> args) async {
  final AnyAppPackager appPackager = AnyAppPackager();

  final runner = CommandRunner(
    'any_app_packager',
    'Package your any app into OS-specific bundles (.dmg, .exe, etc.) via Dart or the command line.',
  );
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

  runner.addCommand(PackageCommand(appPackager));

  ArgResults argResults = runner.parse(['package', ...args]);
  return runner.runCommand(argResults);
}
