import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

import 'windows_installer.dart';
import 'windows_installer_inno_setup.dart';

class AppPackageMakerExe extends AppPackageMaker {
  String get name => 'exe';
  String get packageFormat => 'exe';

  bool get isSupportedOnCurrentPlatform => Platform.isWindows;

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
      '${appDirectory.path}/*',
      '${packagingDirectory.path}',
    ]);

    WindowsInstaller windowsInstaller = WindowsInstallerInnoSetup();

    await windowsInstaller.compile(packagingDirectory: packagingDirectory);

    packagingDirectory.deleteSync(recursive: true);
    return makeResult;
  }
}
