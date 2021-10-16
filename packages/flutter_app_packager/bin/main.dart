import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:app_package_maker_deb/app_package_maker_deb.dart';
import 'package:app_package_maker_zip/app_package_maker_zip.dart';
import 'package:args/args.dart';
import 'package:flutter_app_packager/flutter_app_packager.dart';
import 'package:yaml/yaml.dart';

final Directory workDir = Directory.current;

AppInfo _getAppInfo() {
  final yamlString = File('${workDir.path}/pubspec.yaml').readAsStringSync();
  final yamlDoc = loadYaml(yamlString);

  String pubspecName = yamlDoc['name'];
  String pubspecVersion = yamlDoc['version'];

  return AppInfo(
    name: pubspecName,
    buildNumber: pubspecVersion.split('+').last,
    version: pubspecVersion.split('+').first,
  );
}

Future<void> main(List<String> args) async {
  var parser = ArgParser();
  parser.addFlag(
    'help',
    abbr: 'h',
    negatable: false,
  );
  parser.addOption(
    'platform',
    valueHelp: 'name',
  );
  final options = parser.parse(args);

  if (options['help'] == true) {
    print('Usage: flutter_app_packager --platform=linux\n');
    print(parser.usage);
    return;
  }

  final String targetPlatform = options['platform'];

  final FlutterAppPackager appPackager = FlutterAppPackager(
    makers: [
      AppPackageMakerDeb(),
      AppPackageMakerZip(),
    ],
  );

  await appPackager.pack(PackagingOptions(
    workDirectory: workDir,
    appInfo: _getAppInfo(),
    targetPlatform: targetPlatform,
    targets: [kTargetDeb, kTargetZip],
  ));
}
