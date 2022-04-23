import 'dart:convert';
import 'dart:io';
import 'package:app_package_maker/app_package_maker.dart';
import 'make_appimage_config.dart';
import 'package:path/path.dart' as path;

class AppPackageMakerAppImage extends AppPackageMaker {
  String get name => 'appimage';
  String get platform => 'linux';
  String get packageFormat => 'appimage';

  bool get isSupportedOnCurrentPlatform => Platform.isLinux;

  @override
  Future<MakeConfig> loadMakeConfig(
    Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
  ) async {
    MakeConfig baseMakeConfig = await super.loadMakeConfig(
      outputDirectory,
      makeArguments,
    );
    final map = loadMakeConfigYaml('linux/packaging/appimage/make_config.yaml');
    return MakeAppImageConfig.fromJson(map).copyWith(baseMakeConfig);
  }

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
    void Function(List<int> data)? onProcessStdOut,
    void Function(List<int> data)? onProcessStdErr,
  }) async {
    MakeAppImageConfig makeConfig = await loadMakeConfig(
      outputDirectory,
      makeArguments,
    ) as MakeAppImageConfig;

    final configFile = File("AppImageBuilder.yml");
    final outputFile =
        File("${makeConfig.appName}-${makeConfig.appVersion}-x86_64.AppImage");
    final appDir = Directory("AppDir");
    final buildDir = Directory("appimage-build");

    if (!configFile.existsSync()) configFile.createSync();
    // removing already used AppDir & appimage-build directories
    configFile.writeAsStringSync(jsonEncode(makeConfig.toJson()));

    final process = await Process.start('appimage-builder', [
      "--recipe",
      configFile.path,
    ]);

    process.stdout.listen(onProcessStdOut);
    process.stderr.listen(onProcessStdErr);

    int exitCode = await process.exitCode;
    if (exitCode != 0) {
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
        "${makeConfig.appName}-${makeConfig.appVersion}-$platform.AppImage",
      ),
    );

    return MakeResult(makeConfig);
  }
}
