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
      packedFileExt: 'deb',
    );

    Directory packingDirectory = appPackageInfo.packingDirectory;
    if (packingDirectory.existsSync())
      packingDirectory.deleteSync(recursive: true);
    packingDirectory.createSync(recursive: true);

    Process.runSync('cp', [
      '-fr',
      'linux/packaging/deb/.',
      '${packingDirectory.path}',
    ]);
    Process.runSync('cp', [
      '-fr',
      '${appDirectory.path}/.',
      '${packingDirectory.path}/usr/bin',
    ]);
    Process.runSync('dpkg-deb', [
      '--build',
      '--root-owner-group',
      '${packingDirectory.path}',
    ]);
    packingDirectory.deleteSync(recursive: true);
    return appPackageInfo.packedFile.path;
  }
}
