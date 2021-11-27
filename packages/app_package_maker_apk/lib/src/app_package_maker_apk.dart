import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerApk extends AppPackageMaker {
  String get name => 'apk';
  String get packageFormat => 'apk';

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

    File apkFile = appDirectory
        .listSync()
        .where((e) => e.path.endsWith(packageFormat))
        .map((e) => File(e.path))
        .first;

    Process.runSync('cp', [
      '-fr',
      apkFile.path,
      makeResult.outputPackageFile.path,
    ]);

    return makeResult;
  }
}
