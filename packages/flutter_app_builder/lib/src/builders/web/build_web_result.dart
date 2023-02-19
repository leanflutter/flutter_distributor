import 'dart:io';

import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/build_result.dart';

class BuildWebResultResolver extends BuildResultResolver {
  @override
  BuildResult resolve(BuildConfig config, {Duration? duration}) {
    return BuildWebResult(config)..duration = duration;
  }
}

class BuildWebResult extends BuildResult {
  BuildWebResult(BuildConfig config) : super(config);

  @override
  Directory get outputDirectory {
    String path = 'build/web';
    return Directory(path);
  }
}
