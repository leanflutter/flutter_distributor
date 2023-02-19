import 'dart:io';

import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/build_result.dart';
import 'package:recase/recase.dart';

class BuildWindowsResultResolver extends BuildResultResolver {
  @override
  BuildResult resolve(BuildConfig config, {Duration? duration}) {
    return BuildWindowsResult(config)..duration = duration;
  }
}

class BuildWindowsResult extends BuildResult {
  BuildWindowsResult(BuildConfig config) : super(config);

  @override
  Directory get outputDirectory {
    String buildMode = ReCase(config.mode.name).sentenceCase;
    String path = 'build/windows/runner/${buildMode}';
    return Directory(path);
  }
}
