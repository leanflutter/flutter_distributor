import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerDeb extends AppPackageMaker {
  String get name => 'deb';
  String get packageFormat => 'deb';

  bool get isSupportedOnCurrentPlatform => Platform.isLinux;

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
      '-fr',
      'linux/packaging/deb/.',
      '${packagingDirectory.path}',
    ]);
    Process.runSync('cp', [
      '-fr',
      '${appDirectory.path}/.',
      '${packagingDirectory.path}/usr/lib/${makeConfig.appName}/',
    ]);
    Process.runSync('dpkg-deb', [
      '--build',
      '--root-owner-group',
      '${packagingDirectory.path}',
    ]);
    packagingDirectory.deleteSync(recursive: true);
    return makeResult;
  }
}
