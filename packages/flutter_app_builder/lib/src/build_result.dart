import 'dart:io';

import 'package:flutter_app_builder/src/build_config.dart';

abstract class BuildResult {
  final BuildConfig config;
  Duration? duration;
  Directory get outputDirectory;
  List<File> outputFiles;

  BuildResult(
    this.config, {
    this.duration,
    this.outputFiles = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'config': config.toJson(),
      'outputDirectory': outputDirectory.path,
      'duration': duration?.inMilliseconds,
      'outputFiles': outputFiles.map((e) => e.path).toList(),
    }..removeWhere((key, value) => value == null);
  }
}

abstract class BuildResultResolver {
  BuildResult resolve(BuildConfig config);
}
