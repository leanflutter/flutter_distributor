import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:flutter_app_builder/flutter_app_builder.dart';
import 'package:flutter_app_packager/flutter_app_packager.dart';

class FlutterDistributor {
  final FlutterAppBuilder _builder = FlutterAppBuilder();
  final FlutterAppPackager _packager = FlutterAppPackager();

  Future<void> release({
    required String targetPlatform,
    required List<String> targets,
  }) async {
    Directory outputDirectory = Directory('dist/');

    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }

    bool isBuildOnlyOnce = targetPlatform != 'android';
    BuildResult? buildResult;

    for (String target in targets) {
      if (!isBuildOnlyOnce || (isBuildOnlyOnce && buildResult == null)) {
        buildResult = await _builder.build(targetPlatform, target, {});
      }
      if (buildResult != null) {
        MakeResult makeResult = await _packager.package(
          buildResult.outputDirectory,
          platform: targetPlatform,
          target: target,
          outputDirectory: outputDirectory,
        );
        print('Packaged: ${makeResult.outputFile}');
      }
    }

    return Future.value();
  }
}
