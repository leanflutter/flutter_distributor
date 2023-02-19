import 'dart:io';

import 'package:flutter_app_builder/src/build_artifact.dart';
import 'package:flutter_app_builder/src/build_config.dart';

abstract class BuildResult {
  final BuildConfig config;
  Duration? duration;
  Directory get outputDirectory;
  List<BuildArtifact> artifacts;

  BuildResult(
    this.config, {
    this.duration,
    this.artifacts = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'config': config.toJson(),
      'outputDirectory': outputDirectory.path,
      'duration': duration?.inMilliseconds,
      'artifacts': artifacts.map((e) => e.toJson()).toList(),
    }..removeWhere((key, value) => value == null);
  }
}

abstract class BuildResultResolver {
  BuildResult resolve(BuildConfig config, {Duration? duration});
}
