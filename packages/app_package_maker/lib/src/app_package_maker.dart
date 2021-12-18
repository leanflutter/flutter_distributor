import 'dart:convert';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

const _kArtifactName = '{name}-{flavor}-{version}-{platform}.{ext}';
const _kArtifactNameNoFlavor = '{name}-{version}-{platform}.{ext}';

Map<String, dynamic> loadMakeConfigYaml(String path) {
  final yamlDoc = loadYaml(File(path).readAsStringSync());
  return json.decode(json.encode(yamlDoc));
}

abstract class AppPackageMaker {
  String get name => throw UnimplementedError();
  String get platform => throw UnimplementedError();
  String get packageFormat => throw UnimplementedError();

  bool get isSupportedOnCurrentPlatform => true;

  Future<MakeConfig> loadMakeConfig() async {
    return MakeConfig()
      ..platform = platform
      ..packageFormat = packageFormat;
  }

  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    String? flavor,
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
  String? artifactName;
  late bool isInstaller = false;
  late String platform;
  String? flavor;
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
      'flavor': flavor,
      'ext': packageFormat,
    }..removeWhere((key, value) => value == null);

    String filename = flavor != null ? _kArtifactName : _kArtifactNameNoFlavor;
    if (artifactName != null) filename = artifactName!;

    for (String key in variables.keys) {
      dynamic value = variables[key];
      filename = filename.replaceAll('{$key}', value);
    }

    if (isInstaller) {
      filename = filename.replaceAll(
        '.$packageFormat',
        '-setup.$packageFormat}',
      );
    }

    Directory versionOutputDirectory =
        Directory('${outputDirectory.path}${appVersion}');

    if (!versionOutputDirectory.existsSync()) {
      versionOutputDirectory.createSync(recursive: true);
    }

    return File('${versionOutputDirectory.path}/$filename');
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
