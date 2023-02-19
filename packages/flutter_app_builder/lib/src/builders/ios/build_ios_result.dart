import 'dart:io';

import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/build_result.dart';

class BuildIosResultResolver extends BuildResultResolver {
  @override
  BuildResult resolve(BuildConfig config, {Duration? duration}) {
    return BuildIosResult(config)..duration = duration;
  }
}

class BuildIosResult extends BuildResult {
  BuildIosResult(BuildConfig config) : super(config);

  @override
  Directory get outputDirectory {
    String path = 'build/ios/ipa';
    return Directory(path);
  }
}
