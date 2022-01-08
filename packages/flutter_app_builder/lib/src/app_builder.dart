import 'dart:convert';
import 'dart:io';

typedef ProcessStdOutCallback = void Function(String message);
typedef ProcessStdErrCallback = void Function(String message);

class AppBuilder {
  String get platform => throw UnimplementedError();

  bool get isSupportedOnCurrentPlatform => throw UnimplementedError();

  String get buildSubcommand => platform;

  Directory get outputDirectory => throw UnimplementedError();

  Future<BuildResult> build({
    String? target,
    required bool cleanOnceBeforeBuild,
    required Map<String, dynamic> buildArguments,
    required ProcessStdOutCallback onProcessStdOut,
    required ProcessStdErrCallback onProcessStdErr,
  }) async {
    if (cleanOnceBeforeBuild) {
      Process process = await Process.start(
        'flutter',
        ['clean'],
        runInShell: true,
      );
      process.stdout.listen((event) {
        onProcessStdOut(utf8.decoder.convert(event).trim());
      });
      process.stderr.listen((event) {
        onProcessStdErr(utf8.decoder.convert(event).trim());
      });

      await process.exitCode;
    }

    List<String> arguments = [];
    for (String key in buildArguments.keys) {
      dynamic value = buildArguments[key];
      if (value is Map) {
        for (String subKey in value.keys) {
          arguments.addAll(['--$key', '$subKey=${value[subKey]}']);
        }
      } else {
        arguments.addAll(['--$key', value]);
      }
    }

    Process process = await Process.start(
      'flutter',
      ['build', buildSubcommand]..addAll(arguments),
      runInShell: true,
    );
    process.stdout.listen((event) {
      onProcessStdOut(utf8.decoder.convert(event).trim());
    });
    process.stderr.listen((event) {
      onProcessStdErr(utf8.decoder.convert(event).trim());
    });

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
