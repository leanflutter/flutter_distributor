import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:app_package_maker_apk/app_package_maker_apk.dart';
import 'package:app_package_maker_deb/app_package_maker_deb.dart';
import 'package:app_package_maker_dmg/app_package_maker_dmg.dart';
import 'package:app_package_maker_exe/app_package_maker_exe.dart';
import 'package:app_package_maker_zip/app_package_maker_zip.dart';
import 'package:args/args.dart';
import 'package:flutter_app_packager/flutter_app_packager.dart';
import 'package:yaml/yaml.dart';

AppInfo _getAppInfo() {
  final yamlString = File('pubspec.yaml').readAsStringSync();
  final yamlDoc = loadYaml(yamlString);

  String pubspecName = yamlDoc['name'];
  String pubspecVersion = yamlDoc['version'];

  return AppInfo(
    name: pubspecName,
    buildNumber: pubspecVersion.split('+').last,
    version: pubspecVersion.split('+').first,
  );
}

List<String> _getTargets(String targetPlatform) {
  switch (targetPlatform) {
    case 'android':
      return [kTargetApk];
    case 'linux':
      return [kTargetDeb, kTargetZip];
    case 'macos':
      return [kTargetDmg, kTargetZip];
    case 'web':
      return [kTargetZip];
    case 'windows':
      return [kTargetExe, kTargetZip];
    default:
      throw UnsupportedError('Unsupported target platform: $targetPlatform.');
  }
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
      AppPackageMakerApk(),
      AppPackageMakerDeb(),
      AppPackageMakerDmg(),
      AppPackageMakerExe(),
      AppPackageMakerZip(),
    ],
  );

  await appPackager.pack(PackagingOptions(
    appInfo: _getAppInfo(),
    targetPlatform: targetPlatform,
    targets: _getTargets(targetPlatform),
  ));
}
