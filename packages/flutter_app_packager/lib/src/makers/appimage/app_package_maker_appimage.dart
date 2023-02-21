import 'dart:convert';
import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:flutter_app_packager/src/makers/appimage/make_appimage_config.dart';
import 'package:path/path.dart' as path;
import 'package:shell_executor/shell_executor.dart';

class AppPackageMakerAppImage extends AppPackageMaker {
  String get name => 'appimage';
  String get platform => 'linux';
  bool get isSupportedOnCurrentPlatform => Platform.isLinux;
  String get packageFormat => 'appimage';

  MakeConfigLoader get configLoader {
    return MakeAppImageConfigLoader()
      ..platform = platform
      ..packageFormat = packageFormat;
  }

  @override
  Future<MakeResult> make(MakeConfig config) {
    return _make(
      config.buildOutputDirectory,
      outputDirectory: config.outputDirectory,
      makeConfig: config as MakeAppImageConfig,
    );
  }

  Future<MakeResult> _make(
    Directory appDirectory, {
    required Directory outputDirectory,
    required MakeAppImageConfig makeConfig,
  }) async {
    final configFile = File('AppImageBuilder.yml');
    final outputFile =
        File('${makeConfig.appName}-${makeConfig.appVersion}-x86_64.AppImage');
    final appDir = Directory('AppDir');
    final buildDir = Directory('appimage-build');

    if (!configFile.existsSync()) configFile.createSync();
    // removing already used AppDir & appimage-build directories
    configFile.writeAsStringSync(jsonEncode(makeConfig.toJson()));

    ProcessResult processResult = await $(
      'appimage-builder',
      ['--recipe', configFile.path],
    );

    if (processResult.exitCode != 0) {
      throw MakeError();
    }

    // delete the config file & cleaning stuff
    await configFile.delete();
    await appDir.delete(recursive: true);
    await buildDir.delete(recursive: true);

    final outputVersionedDir = Directory(
      path.join(outputDirectory.path, makeConfig.appVersion.toString()),
    );

    if (!outputVersionedDir.existsSync())
      outputVersionedDir.createSync(recursive: true);

    // move the output file to outputDirectory
    await outputFile.rename(
      path.join(
        outputDirectory.path,
        makeConfig.appVersion.toString(),
        '${makeConfig.appName}-${makeConfig.appVersion}-$platform.AppImage',
      ),
    );

    return MakeResult(makeConfig);
  }
}
