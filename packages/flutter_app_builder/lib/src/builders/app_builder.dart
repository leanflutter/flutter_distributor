import 'dart:io';

import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/build_error.dart';
import 'package:flutter_app_builder/src/build_result.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:shell_executor/shell_executor.dart';

abstract class AppBuilder {
  String get platform => throw UnimplementedError();
  bool get isSupportedOnCurrentPlatform => throw UnimplementedError();
  BuildResultResolver get resultResolver;
  String get buildSubcommand => platform;

  String get appName => pubspec.name;
  Version get appVersion => pubspec.version!;
  String get appBuildName => appVersion.toString().split('+').first;
  String get appBuildNumber => appVersion.toString().split('+').last;

  Pubspec? _pubspec;

  Pubspec get pubspec {
    if (_pubspec == null) {
      final yamlString = File('pubspec.yaml').readAsStringSync();
      _pubspec = Pubspec.parse(yamlString);
    }
    return _pubspec!;
  }

  Future<BuildResult> build(BuildConfig config) async {
    final time = Stopwatch()..start();

    List<String> arguments = [];
    for (String key in config.arguments.keys) {
      dynamic value = config.arguments[key];
      if (value == null || value is bool) {
        arguments.add('--$key');
      } else if (value is Map) {
        for (String subKey in value.keys) {
          arguments.addAll(['--$key', '$subKey=${value[subKey]}']);
        }
      } else {
        arguments.addAll(['--$key', value]);
      }
    }

    arguments.addAll([
      '--dart-define',
      'FLUTTER_BUILD_NAME=$appBuildName',
      '--dart-define',
      'FLUTTER_BUILD_NUMBER=$appBuildNumber',
    ]);

    ProcessResult processResult = await $(
      'flutter',
      ['build', buildSubcommand]..addAll(arguments),
    );

    if (processResult.exitCode != 0) {
      throw BuildError();
    }

    return resultResolver.resolve(
      config,
      duration: time.elapsed,
    );
  }
}
