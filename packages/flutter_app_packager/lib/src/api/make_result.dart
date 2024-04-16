import 'dart:io';

import 'package:flutter_app_packager/src/api/make_config.dart';
import 'package:flutter_app_packager/src/api/make_error.dart';

class MakeResult {
  MakeResult(
    this.config, {
    this.duration,
  }) : artifacts = config.outputArtifacts;

  final MakeConfig config;
  final List<FileSystemEntity> artifacts;
  final Duration? duration;

  Map<String, dynamic> toJson() {
    return {
      'config': config.toJson(),
      'artifacts': artifacts
          .map(
            (e) => {
              'type': e is File ? 'file' : 'directory',
              'path': e.path,
            },
          )
          .toList(),
      'duration': duration,
    }..removeWhere((key, value) => value == null);
  }
}

abstract class MakeResultResolver {
  MakeResult resolve(MakeConfig config);
}

class DefaultMakeResultResolver extends MakeResultResolver {
  @override
  MakeResult resolve(MakeConfig config) {
    MakeResult makeResult = MakeResult(config);
    for (var artifact in makeResult.artifacts) {
      if (artifact is File) {
        if (!artifact.existsSync()) {
          throw MakeError('No output file found.');
        }
      } else if (artifact is Directory) {
        if (!artifact.existsSync()) {
          throw MakeError('No output directory found.');
        }
      }
    }
    return makeResult;
  }
}
