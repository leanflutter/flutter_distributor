import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

const String kTargetApk = 'apk';

class AppPackageMakerApk extends AppPackageMaker {
  String get target => kTargetApk;

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
      packagedFileExt: 'apk',
    );

    Process.runSync('cp', [
      '-fr',
      '${appDirectory.path}/app-release.apk',
      appPackageInfo.packagedFile.path,
    ]);

    return appPackageInfo.packagedFile.path;
  }
}
