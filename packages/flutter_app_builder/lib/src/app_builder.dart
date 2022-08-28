import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:shell_executor/shell_executor.dart';

class AppBuilder {
  String get platform => throw UnimplementedError();
  bool get isSupportedOnCurrentPlatform => throw UnimplementedError();
  String get buildSubcommand => platform;
  Directory get outputDirectory => throw UnimplementedError();

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

  Future<BuildResult> build({
    String? target,
    required Map<String, dynamic> buildArguments,
  }) async {
    final time = Stopwatch()..start();

    List<String> arguments = [];
    for (String key in buildArguments.keys) {
      dynamic value = buildArguments[key];
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

    return BuildResult(
      outputDirectory: outputDirectory,
      duration: time.elapsed,
    );
  }
}

class BuildResult {
  final Directory outputDirectory;
  final Duration duration;

  BuildResult({
    required this.outputDirectory,
    required this.duration,
  });
}

class BuildError extends Error {
  final String? message;

  BuildError([this.message]);

  String toString() {
    var message = this.message;
    return (message != null) ? "BuildError: $message" : "BuildError";
  }
}
