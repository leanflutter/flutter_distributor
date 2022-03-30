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
    void Function(List<int> data)? onProcessStdOut,
    void Function(List<int> data)? onProcessStdErr,
  });
}

class MakeConfig {
  String? artifactName;
  late bool isInstaller = false;
  late String platform;
  String? flavor;
  late String packageFormat;
  late Directory outputDirectory;

  String? displayName;
  set disPlayName(String? displayname){
    this.displayName=displayname;
  }

  String get appName => displayName ?? pubspec.name;
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
        '-setup.$packageFormat',
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

class MakeError extends Error {
  final String? message;

  MakeError([this.message]);

  String toString() {
    var message = this.message;
    return (message != null) ? "MakeError: $message" : "MakeError";
  }
}
