import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

import 'windows_installer.dart';
import 'windows_installer_inno_setup.dart';

class AppPackageMakerExe extends AppPackageMaker {
  String get name => 'exe';
  String get platform => 'windows';
  String get packageFormat => 'exe';

  bool get isSupportedOnCurrentPlatform => Platform.isWindows;

  @override
  Future<MakeConfig> loadMakeConfig() async {
    return await super.loadMakeConfig()
      ..isInstaller = true;
  }

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
      '${appDirectory.path}/*',
      '${packagingDirectory.path}',
    ]);

    WindowsInstaller windowsInstaller = WindowsInstallerInnoSetup();

    await windowsInstaller.compile(packagingDirectory: packagingDirectory);

    packagingDirectory.deleteSync(recursive: true);

    return MakeResult(makeConfig);
  }
}
