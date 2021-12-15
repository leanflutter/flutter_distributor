import 'dart:convert';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

const kDefaultArtifactName = '{name}-{version}-{platform}.{ext}';

Map<String, dynamic> loadMakeConfigYaml(String path) {
  final yamlDoc = loadYaml(File(path).readAsStringSync());
  return json.decode(json.encode(yamlDoc));
}

abstract class AppPackageMaker {
  String get name => throw UnimplementedError();
  String get packageFormat => throw UnimplementedError();

  bool get isSupportedOnCurrentPlatform => true;

  Future<MakeConfig> loadMakeConfig() {
    throw UnimplementedError();
  }

  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    String? platform,
  });

  Future<void> exec(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
  }) async {
    Process process = await Process.start(
      executable,
      arguments,
      runInShell: runInShell,
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
  }
}

class MakeConfig {
  late String artifactName = kDefaultArtifactName;
  late bool isInstaller = false;
  late String platform;
  late String packageFormat;
  late Directory outputDirectory;

  String get appName => pubspec.name;
  Version get appVersion => pubspec.version!;

  Pubspec? _pubspec;
  Directory? _packagingDirectory;

  File get outputFile {
    Map<String, dynamic> variables = {
      'name': appName,
      'version': appVersion.toString(),
      'platform': platform,
      'ext': packageFormat,
    };
    String filename = artifactName;
    for (String key in variables.keys) {
      filename = filename.replaceAll('{$key}', variables[key]);
    }

    if (isInstaller) {
      filename = filename.replaceAll(
        '.$packageFormat',
        '-setup.$packageFormat}',
      );
    }

    return File('${outputDirectory.path}${appVersion}/$filename');
  }

  Directory get packagingDirectory {
    if (_packagingDirectory == null) {
      _packagingDirectory = Directory(
          '${outputFile.path.replaceAll('.$packageFormat', '_$packageFormat')}');
      if (_packagingDirectory!.existsSync())
        _packagingDirectory!.deleteSync(recursive: true);
      _packagingDirectory!.createSync(recursive: true);
    }
    return _packagingDirectory!;
  }

  Pubspec get pubspec {
    if (_pubspec == null) {
      final yamlString = File('pubspec.yaml').readAsStringSync();
      _pubspec = Pubspec.parse(yamlString);
    }
    return _pubspec!;
  }
}

class MakeResult {
  final MakeConfig makeConfig;

  File get outputFile => makeConfig.outputFile;

  MakeResult(this.makeConfig);
}
