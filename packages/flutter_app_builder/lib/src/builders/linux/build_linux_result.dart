import 'dart:io';

import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/build_result.dart';

class BuildLinuxResultResolver extends BuildResultResolver {
  @override
  BuildResult resolve(BuildConfig config, {Duration? duration}) {
    return BuildLinuxResult(config)..duration = duration;
  }
}

class BuildLinuxResult extends BuildResult {
  BuildLinuxResult(BuildConfig config) : super(config);

  String? _arch;

  String get arch {
    if (_arch == null) {
      ProcessResult r = Process.runSync('uname', ['-m']);
      if ('${r.stdout}'.trim() == 'aarch64') {
        _arch = 'arm64';
      } else {
        _arch = 'x64';
      }
    }
    return _arch!;
  }

  void set arch(String value) {
    _arch = value;
  }

  @override
  Directory get outputDirectory {
    String buildMode = config.mode.name;
    String path = 'build/linux/$arch/$buildMode/bundle';
    return Directory(path);
  }
}
