import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerDmg extends AppPackageMaker {
  String get name => 'dmg';
  String get packageFormat => 'dmg';

  bool get isSupportedOnCurrentPlatform => Platform.isMacOS;

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

    Directory packagingDirectory = makeResult.packagingDirectory;
    if (packagingDirectory.existsSync())
      packagingDirectory.deleteSync(recursive: true);
    packagingDirectory.createSync(recursive: true);

    Process.runSync('cp', [
      '-RH',
      'macos/packaging/dmg/.',
      '${packagingDirectory.path}',
    ]);

    File appFile = appDirectory
        .listSync()
        .where((e) => e.path.endsWith('.app'))
        .map((e) => File(e.path))
        .first;

    Process.runSync('cp', [
      '-RH',
      appFile.path,
      '${packagingDirectory.path}/',
    ]);
    Process.runSync('appdmg', [
      '${packagingDirectory.path}/appdmg.json',
      makeResult.outputPackageFile.path,
    ]);
    packagingDirectory.deleteSync(recursive: true);

    return makeResult;
  }
}
