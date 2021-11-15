import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

const String kTargetDmg = 'dmg';

class AppPackageMakerDmg extends AppPackageMaker {
  String get target => kTargetDmg;

  @override
  Future<String> make(
    AppInfo appInfo,
    String targetPlatform, {
    required Directory appDirectory,
    required Directory outputDirectory,
  }) async {
    AppPackageInfo appPackageInfo = AppPackageInfo(
      appInfo: appInfo,
      targetPlatform: targetPlatform,
      appDirectory: appDirectory,
      outputDirectory: outputDirectory,
      packagedFileExt: 'dmg',
    );

    Directory packagingDirectory = appPackageInfo.packagingDirectory;
    if (packagingDirectory.existsSync())
      packagingDirectory.deleteSync(recursive: true);
    packagingDirectory.createSync(recursive: true);

    Process.runSync('cp', [
      '-RH',
      'macos/packaging/dmg/.',
      '${packagingDirectory.path}',
    ]);
    Process.runSync('cp', [
      '-RH',
      '${appDirectory.path}/${appPackageInfo.appInfo.name}.app',
      '${packagingDirectory.path}',
    ]);
    Process.runSync('appdmg', [
      '${packagingDirectory.path}/appdmg.json',
      appPackageInfo.packagedFile.path,
    ]);
    packagingDirectory.deleteSync(recursive: true);
    return appPackageInfo.packagedFile.path;
  }
}
