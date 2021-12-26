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
    Map<String, dynamic> buildArguments = const {},
    ProcessStdOutCallback? onBuildProcessStdOut,
    ProcessStdErrCallback? onBuildProcessStdErr,
  }) async {
    List<String> arguments = [];
    for (String key in buildArguments.keys) {
      arguments.addAll(['--$key', buildArguments[key]]);
    }

    Process process = await Process.start(
      'flutter',
      ['build', buildSubcommand]..addAll(arguments),
      runInShell: true,
    );
    process.stdout.listen((event) {
      String msg = utf8.decoder.convert(event).trim();
      if (onBuildProcessStdOut != null) onBuildProcessStdOut(msg);
    });
    process.stderr.listen((event) {
      String msg = utf8.decoder.convert(event).trim();
      if (onBuildProcessStdErr != null) onBuildProcessStdErr(msg);
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
