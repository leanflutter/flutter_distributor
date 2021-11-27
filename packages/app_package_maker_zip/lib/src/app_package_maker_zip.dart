import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:archive/archive_io.dart';

class AppPackageMakerZip extends AppPackageMaker {
  String get name => 'zip';
  String get packageFormat => 'zip';

  @override
  Future<MakeResult> make({
    required Directory appDirectory,
    required String targetPlatform,
    required MakeConfig makeConfig,
  }) async {
    MakeResult makeResult = MakeResult(
      makeConfig: makeConfig,
      targetPlatform: targetPlatform,
      packageFormat: packageFormat,
    );

    if (targetPlatform == 'windows') {
      final zipFileEncoder = ZipFileEncoder();
      zipFileEncoder.zipDirectory(
        appDirectory,
        filename: makeResult.outputPackageFile.path,
      );
    } else {
      String filter = targetPlatform == 'macos' ? '*.app' : '*';
      Process.runSync('7z', [
        'a',
        makeResult.outputPackageFile.path,
        './${appDirectory.path}/$filter',
      ]);
    }
    return makeResult;
  }
}
