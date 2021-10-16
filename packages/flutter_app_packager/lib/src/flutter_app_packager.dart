import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

import 'packaging_options.dart';

class FlutterAppPackager {
  final List<AppPackageMaker> makers;

  FlutterAppPackager({
    required this.makers,
  });

  Directory _getBuildOutputDirectory(
    Directory workDirectory,
    String targetPlatform,
  ) {
    String dir = workDirectory.path;
    switch (targetPlatform) {
      case 'linux':
        return Directory('${dir}/build/linux/x64/release/bundle');
      case 'macos':
        return Directory('${dir}/build/macos/Build/Products/Release');
      case 'windows':
        return Directory('${dir}/build/windows/runner/Release');
      default:
        throw UnsupportedError('Unsupported target platform: $targetPlatform.');
    }
  }

  Future<void> pack(PackagingOptions options) async {
    Directory buildOutputDirectory = _getBuildOutputDirectory(
      options.workDirectory,
      options.targetPlatform,
    );

    Directory inputDir = options.binaryArchiveDir;
    if (inputDir.existsSync()) inputDir.deleteSync(recursive: true);
    inputDir.createSync(recursive: true);

    await Process.run('cp', [
      '-fr',
      '${buildOutputDirectory.path}/.',
      inputDir.path,
    ]);

    for (String target in options.targets) {
      AppPackageMaker appPackageMaker = makers.firstWhere(
        (e) => e.target == target,
      );
      await appPackageMaker.make(
        options.appInfo,
        options.targetPlatform,
        inputDir: inputDir,
        outputDir: options.outputDirectory,
      );
    }
    inputDir.deleteSync(recursive: true);
  }
}
