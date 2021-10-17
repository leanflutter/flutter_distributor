import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

import 'packaging_options.dart';

class FlutterAppPackager {
  final List<AppPackageMaker> makers;

  FlutterAppPackager({
    required this.makers,
  });

  Directory _getBuildOutputDirectory(
    String targetPlatform,
  ) {
    switch (targetPlatform) {
      case 'linux':
        return Directory('build/linux/x64/release/bundle');
      case 'macos':
        return Directory('build/macos/Build/Products/Release');
      case 'windows':
        return Directory('build/windows/runner/Release');
      default:
        throw UnsupportedError('Unsupported target platform: $targetPlatform.');
    }
  }

  Future<void> pack(PackagingOptions options) async {
    Directory buildOutputDirectory = _getBuildOutputDirectory(
      options.targetPlatform,
    );

    Directory outputDirectory = options.outputDirectory;
    Directory appDirectory = options.appDirectory;
    if (outputDirectory.existsSync())
      outputDirectory.deleteSync(recursive: true);
    outputDirectory.createSync(recursive: true);
    if (appDirectory.existsSync()) appDirectory.deleteSync(recursive: true);
    appDirectory.createSync(recursive: true);

    await Process.run('cp', [
      '-fr',
      '${buildOutputDirectory.path}/.',
      appDirectory.path,
    ]);

    for (String target in options.targets) {
      AppPackageMaker appPackageMaker = makers.firstWhere(
        (e) => e.target == target,
      );
      String pkgPath = await appPackageMaker.make(
        options.appInfo,
        options.targetPlatform,
        appDirectory: appDirectory,
        outputDirectory: outputDirectory,
      );
      print('Packed: $pkgPath');
    }
    appDirectory.deleteSync(recursive: true);
  }
}
