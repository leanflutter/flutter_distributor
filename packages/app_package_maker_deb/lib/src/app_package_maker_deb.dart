import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

const String kTargetDeb = 'deb';

class AppPackageMakerDeb extends AppPackageMaker {
  String get target => kTargetDeb;

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
      packagedFileExt: 'deb',
    );

    Directory packagingDirectory = appPackageInfo.packagingDirectory;
    if (packagingDirectory.existsSync())
      packagingDirectory.deleteSync(recursive: true);
    packagingDirectory.createSync(recursive: true);

    Process.runSync('cp', [
      '-fr',
      'linux/packaging/deb/.',
      '${packagingDirectory.path}',
    ]);
    Process.runSync('cp', [
      '-fr',
      '${appDirectory.path}/.',
      '${packagingDirectory.path}/usr/lib/${appInfo.name}/',
    ]);
    Process.runSync('dpkg-deb', [
      '--build',
      '--root-owner-group',
      '${packagingDirectory.path}',
    ]);
    packagingDirectory.deleteSync(recursive: true);
    return appPackageInfo.packagedFile.path;
  }
}
