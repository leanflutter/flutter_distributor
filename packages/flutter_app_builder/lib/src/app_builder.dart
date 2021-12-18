import 'dart:convert';
import 'dart:io';

class AppBuilder {
  String get platform => throw UnimplementedError();

  bool get isSupportedOnCurrentPlatform => throw UnimplementedError();

  String get buildSubcommand => platform;

  Directory get outputDirectory => throw UnimplementedError();

  Future<BuildResult> build({
    String? target,
    Map<String, dynamic> buildArguments = const {},
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
      String log = utf8.decoder.convert(event).trim();
      print(log);
    });
    process.stderr.listen((event) {
      String log = utf8.decoder.convert(event).trim();
      print(log);
    });

    int exitCode = await process.exitCode;
    print('exitCode: $exitCode');

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
