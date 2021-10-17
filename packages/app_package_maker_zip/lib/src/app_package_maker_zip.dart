import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:archive/archive_io.dart';

const String kTargetZip = 'zip';

class AppPackageMakerZip extends AppPackageMaker {
  String get target => kTargetZip;

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
      packagedFileExt: 'zip',
    );

    if (targetPlatform == 'windows') {
      final zipFileEncoder = ZipFileEncoder();
      zipFileEncoder.zipDirectory(
        appDirectory,
        filename: appPackageInfo.packagedFile.path,
      );
    } else {
      String filter = targetPlatform == 'macos' ? '*.app' : '*';
      Process.runSync('7z', [
        'a',
        appPackageInfo.packagedFile.path,
        './${appDirectory.path}/$filter',
      ]);
    }
    return appPackageInfo.packagedFile.path;
  }
}
