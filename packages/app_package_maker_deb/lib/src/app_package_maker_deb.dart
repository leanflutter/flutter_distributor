import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerDeb extends AppPackageMaker {
  String get name => 'deb';
  String get platform => 'linux';
  String get packageFormat => 'deb';

  bool get isSupportedOnCurrentPlatform => Platform.isLinux;

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    String? flavor,
  }) async {
    MakeConfig makeConfig = await loadMakeConfig()
      ..outputDirectory = outputDirectory;
    Directory packagingDirectory = makeConfig.packagingDirectory;

    Process.runSync('cp', [
      '-fr',
      'linux/packaging/deb/.',
      '${packagingDirectory.path}',
    ]);
    Process.runSync('mkdir', [
      '-p',
      '${packagingDirectory.path}/usr/lib/${makeConfig.appName}/',
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
    return MakeResult(makeConfig);
  }
}
