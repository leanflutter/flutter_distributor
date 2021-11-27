import 'dart:convert';
import 'dart:io';

class BuildResult {
  final Directory outputDirectory;

  BuildResult({
    required this.outputDirectory,
  });
}

class AppBuilder {
  String get platform => throw UnimplementedError();

  Directory getOutputDirectory({
    String? flavor,
    String? target,
  }) =>
      throw UnimplementedError();

  Future<BuildResult> build({
    String? entryPoint,
    String? flavor,
    String? target,
    bool verbose = false,
  }) async {
    String buildSubcommand = platform;
    if (platform == 'android') {
      buildSubcommand = target == 'aab' ? 'appbundle' : 'apk';
    } else if (platform == 'ios') {
      buildSubcommand = 'ipa';
    }
    List<String> arguments = [];
    if (verbose) {
      arguments.add('--verbose');
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
      outputDirectory: this.getOutputDirectory(
        flavor: flavor,
        target: target,
      ),
    );
  }
}
