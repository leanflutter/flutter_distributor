import 'dart:convert';
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

  String? _arch;

  String get arch {
    if (_arch == null) {
      final winArch = Platform.environment['PROCESSOR_ARCHITECTURE'];
      if (winArch == 'ARM64') {
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

  bool isVersionGreaterOrEqual(String fromVersion, String toVersion) {
    if (fromVersion == toVersion) {
      return true;
    }

    final from = fromVersion.split('.').map(int.parse).toList();
    final to = toVersion.split('.').map(int.parse).toList();

    if (from[0] > to[0]) {
      return true;
    } else if (from[0] == to[0] && from[1] > to[1]) {
      return true;
    } else if (from[0] == to[0] && from[1] == to[1] && from[2] > to[2]) {
      return true;
    }
    return false;
  }

  @override
  Directory get outputDirectory {
    String buildMode = ReCase(config.mode.name).sentenceCase;
    final versionInfo = jsonDecode(
      Process.runSync('flutter', ['--version', '--machine'], runInShell: true)
          .stdout
          .toString(),
    ) as Map<String, dynamic>;

    final flutterVersion = versionInfo['frameworkVersion'] as String;
    final flutterChannel = versionInfo['channel'] as String;

    String path;
    if ((flutterChannel == 'master' &&
            isVersionGreaterOrEqual(flutterVersion, '3.15.0')) ||
        (flutterChannel != 'master' &&
            isVersionGreaterOrEqual(flutterVersion, '3.16.0'))) {
      path = 'build/windows/$arch/runner/$buildMode';
    } else {
      path = 'build/windows/runner/$buildMode';
    }
    return Directory(path);
  }
}
