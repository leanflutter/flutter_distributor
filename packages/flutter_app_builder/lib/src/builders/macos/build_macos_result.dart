import 'dart:io';

import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/build_result.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:recase/recase.dart';

class BuildMacOsResultResolver extends BuildResultResolver {
  @override
  BuildResult resolve(BuildConfig config) {
    final r = BuildMacOsResult(config);
    final String pattern = '${r.outputDirectory.path}/**.app';
    r.outputFiles = Glob(pattern).listSync().map((e) => File(e.path)).toList();
    return r;
  }
}

class BuildMacOsResult extends BuildResult {
  BuildMacOsResult(BuildConfig config) : super(config);

  @override
  Directory get outputDirectory {
    String buildMode = ReCase(config.mode.name).sentenceCase;
    String path = 'build/macos/Build/Products/$buildMode';
    return Directory(path);
  }
}
