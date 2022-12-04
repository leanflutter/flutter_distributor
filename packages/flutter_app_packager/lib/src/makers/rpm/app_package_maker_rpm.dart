import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:app_package_maker/app_package_maker.dart';
import 'package:shell_executor/shell_executor.dart';

import 'make_rpm_config.dart';

class AppPackageMakerRPM extends AppPackageMaker {
  String get name => 'rpm';
  String get platform => 'linux';
  String get packageFormat => 'rpm';

  bool get isSupportedOnCurrentPlatform => Platform.isLinux;

  @override
  Future<MakeConfig> loadMakeConfig(
      Directory outputDirectory, Map<String, dynamic>? makeArguments) async {
    final makeConfig =
        await super.loadMakeConfig(outputDirectory, makeArguments);
    return MakeRPMConfig.fromJson(
            loadMakeConfigYaml("linux/packaging/rpm/make_config.yaml"))
        .copyWith(makeConfig);
  }

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
  }) async {
    MakeRPMConfig makeConfig = await loadMakeConfig(
      outputDirectory,
      makeArguments,
    ) as MakeRPMConfig;

    final files = makeConfig.toFilesString();

    Directory packagingDirectory = makeConfig.packagingDirectory;

    // making rpm setup directory

    final rpmbuild = [
      "BUILD",
      "BUILDROOT",
      "RPMS",
      "SOURCES",
      "SPECS",
      "SRPMS",
    ];

    final rpmbuildDirPath =
        path.join(packagingDirectory.absolute.path, "rpmbuild");

    for (final dir in rpmbuild) {
      final dirPath = path.join(rpmbuildDirPath, dir);
      final dirFile = Directory(dirPath);
      if (!dirFile.existsSync()) {
        dirFile.createSync(recursive: true);
      }
    }

    // making rpmbuild/BUILD/[appName] directory
    final buildPath = path.join(rpmbuildDirPath, "BUILD");
    final buildRoot = path.join(buildPath, makeConfig.appName);
    final specsPath = path.join(rpmbuildDirPath, "SPECS");
    final rpmPath =
        path.join(rpmbuildDirPath, "RPMS", makeConfig.buildArch ?? "x86_64");
    final buildWivesDirFile = Directory(buildRoot);
    if (!buildWivesDirFile.existsSync()) {
      buildWivesDirFile.createSync(recursive: true);
    }

    /// copying app files to rpmbuild/BUILD/[appName] directory
    final bundleFiles = appDirectory.listSync();
    for (final file in bundleFiles) {
      await $(
        "cp",
        [
          "-r",
          file.path,
          buildRoot,
        ],
      );
    }

    final iconFile = makeConfig.icon != null
        ? File(path.join(Directory.current.path, makeConfig.icon!))
        : null;

    iconFile?.copy(path.join(buildPath, "${makeConfig.appName}.png"));

    if (makeConfig.icon != null) {
      final iconFile = File(makeConfig.icon!);
      if (!iconFile.existsSync())
        throw MakeError("provided icon ${makeConfig.icon} path wasn't found");
    }

    // create & write the files got from makeConfig
    final specFile = File(path.join(specsPath, "${makeConfig.appName}.spec"));
    final desktopEntryFile =
        File(path.join(buildPath, "${makeConfig.appName}.desktop"));

    if (!specFile.existsSync()) specFile.createSync();
    if (!desktopEntryFile.existsSync()) desktopEntryFile.createSync();

    await specFile.writeAsString(files["SPEC"]!);
    await desktopEntryFile.writeAsString(files["DESKTOP"]!);

    // make the rpm
    final processResult = await $(
      "rpmbuild",
      [
        "--define",
        "_topdir ${rpmbuildDirPath}",
        "-bb",
        specFile.path,
      ],
      environment: {"QA_RPATHS": (0x0001 | 0x0002 | 0x0010).toString()},
    );

    if (processResult.exitCode != 0) {
      throw MakeError();
    }

    final rpms = Directory(rpmPath).listSync();
    for (var rpm in rpms) {
      if (rpm is! File) continue;
      await $(
        "cp",
        [
          rpm.path,
          makeConfig.outputFile.path,
        ],
      );
      break;
    }
    packagingDirectory.deleteSync(recursive: true);
    return MakeResult(makeConfig);
  }
}
