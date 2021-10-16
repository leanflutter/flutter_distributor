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
    required Directory inputDir,
    required Directory outputDir,
  }) async {
    AppPackageInfo appPackageInfo = AppPackageInfo(
      appInfo: appInfo,
      targetPlatform: targetPlatform,
      format: 'zip',
    );

    String outputFilepath = '${outputDir.path}/${appPackageInfo.filename}';
    if (targetPlatform == 'linux') {
      Process.runSync('7z', ['a', outputFilepath, '${inputDir.path}/*']);
    } else {
      final zipFileEncoder = ZipFileEncoder();
      zipFileEncoder.zipDirectory(
        inputDir,
        filename: outputFilepath,
      );
    }
    return outputFilepath;
  }
}
