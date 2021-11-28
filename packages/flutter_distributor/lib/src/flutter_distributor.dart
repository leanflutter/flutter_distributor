import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:flutter_app_builder/flutter_app_builder.dart';
import 'package:flutter_app_packager/flutter_app_packager.dart';
// import 'package:flutter_app_publisher/flutter_app_publisher.dart';

class FlutterDistributor {
  final FlutterAppBuilder _builder = FlutterAppBuilder();
  final FlutterAppPackager _packager = FlutterAppPackager();
  // final FlutterAppPublisher _publisher = FlutterAppPublisher();

  Future<void> release({
    required String appName,
    required String appVersion,
    required String targetPlatform,
    required List<String> targets,
  }) async {
    Directory outputDirectory = Directory('dist/v${appVersion}');

    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }

    bool isBuildOnlyOnce = targetPlatform != 'android';
    BuildResult? buildResult;

    for (var target in targets) {
      if (!isBuildOnlyOnce || (isBuildOnlyOnce && buildResult == null)) {
        buildResult = await _builder.build(
          platform: targetPlatform,
          target: target,
        );
      }
      if (buildResult != null) {
        MakeResult makeResult = await _packager.package(
          appName: appName,
          appVersion: appVersion,
          appDirectory: buildResult.outputDirectory,
          targetPlatform: targetPlatform,
          target: target,
          outputDirectory: outputDirectory,
        );
        print('Packaged: ${makeResult.outputPackageFile}');
      }
    }

    return Future.value();
  }
}
