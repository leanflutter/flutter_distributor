import 'dart:io';

import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/build_result.dart';
import 'package:flutter_app_builder/src/commands/flutter.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:recase/recase.dart';

bool currentVersionIsGreaterOrEqual(Version version, String versionString) {
  return version.compareTo(Version.parse(versionString)) >= 0;
}

class BuildWindowsResultResolver extends BuildResultResolver {
  @override
  BuildResult resolve(BuildConfig config, {Duration? duration}) {
    return BuildWindowsResult(config)..duration = duration;
  }
}

class BuildWindowsResult extends BuildResult {
  BuildWindowsResult(BuildConfig config) : super(config);

  FlutterVersion? _flutterVersion;

  FlutterVersion get flutterVersion {
    _flutterVersion ??= flutter.version;
    return _flutterVersion!;
  }

  set flutterVersion(FlutterVersion value) {
    _flutterVersion = value;
  }

  String? _arch;

  String get arch {
    if (_arch == null) {
      final processorArchitecture =
          Platform.environment['PROCESSOR_ARCHITECTURE'];
      if (processorArchitecture?.toUpperCase() == 'ARM64') {
        _arch = 'arm64';
      } else {
        _arch = 'x64';
      }
    }
    return _arch!;
  }

  set arch(String value) {
    _arch = value;
  }

  @override
  Directory get outputDirectory {
    String buildMode = ReCase(config.mode.name).sentenceCase;
    String path = 'build/windows/$arch/runner/$buildMode';
    if (!flutterVersion.isGreaterOrEqual('3.15.0')) {
      path = 'build/windows/runner/$buildMode';
    }
    return Directory(path);
  }
}
