import 'dart:io';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

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
    required bool cleanBeforeBuild,
    required Map<String, dynamic> buildArguments,
    required void Function(List<int> data) onProcessStdOut,
    required void Function(List<int> data) onProcessStdErr,
  }) async {
    if (cleanBeforeBuild) {
      Process process = await Process.start(
        'flutter',
        ['clean'],
        runInShell: true,
      );
      process.stdout.listen(onProcessStdOut);
      process.stderr.listen(onProcessStdErr);
      await process.exitCode;
    }

    List<String> arguments = [];
    for (String key in buildArguments.keys) {
      dynamic value = buildArguments[key];
      if (value == null) {
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

    print(
      (['flutter', 'build', buildSubcommand]..addAll(arguments)).join(' '),
    );

    Process process = await Process.start(
      'flutter',
      ['build', buildSubcommand]..addAll(arguments),
      runInShell: true,
    );
    process.stdout.listen(onProcessStdOut);
    process.stderr.listen(onProcessStdErr);

    int exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw BuildError();
    }

    return BuildResult(
      outputDirectory: outputDirectory,
    );
  }
}

class BuildResult {
  final Directory outputDirectory;

  BuildResult({
    required this.outputDirectory,
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
