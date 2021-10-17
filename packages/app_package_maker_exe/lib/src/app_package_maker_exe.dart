import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

import 'windows_installer.dart';
import 'windows_installer_inno_setup.dart';

const String kTargetExe = 'exe';

class AppPackageMakerExe extends AppPackageMaker {
  String get target => kTargetExe;

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
      packagedFileExt: 'exe',
      packagedFileIsInstaller: true,
    );

    Directory packagingDirectory = appPackageInfo.packagingDirectory;
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
    return appPackageInfo.packagedFile.path;
  }
}
