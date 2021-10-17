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
      packedFileExt: 'zip',
    );

    if (targetPlatform == 'linux') {
      Process.runSync('7z', [
        'a',
        appPackageInfo.packedFile.path,
        './${appDirectory.path}/*',
      ]);
    } else {
      final zipFileEncoder = ZipFileEncoder();
      zipFileEncoder.zipDirectory(
        appDirectory,
        filename: appPackageInfo.packedFile.path,
      );
    }
    return appPackageInfo.packedFile.path;
  }
}
