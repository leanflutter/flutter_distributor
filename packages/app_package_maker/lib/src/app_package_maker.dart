import 'dart:convert';
import 'dart:io';

import 'package:mustache_template/mustache_template.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

const _kArtifactName =
    '{{name}}{{#flavor}}-{{flavor}}{{/flavor}}-{{build_name}}+{{build_number}}-{{platform}}{{#is_installer}}-setup{{/is_installer}}.{{ext}}';
const _kArtifactNameWithChannel =
    '{{name}}-{{channel}}-{{build_name}}+{{build_number}}-{{platform}}{{#is_installer}}-setup{{/is_installer}}.{{ext}}';

Map<String, dynamic> loadMakeConfigYaml(String path) {
  final yamlDoc = loadYaml(File(path).readAsStringSync());
  return json.decode(json.encode(yamlDoc));
}

abstract class AppPackageMaker {
  String get name => throw UnimplementedError();
  String get platform => throw UnimplementedError();
  String get packageFormat => throw UnimplementedError();

  bool get isSupportedOnCurrentPlatform => true;

  Future<MakeConfig> loadMakeConfig(
    Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
  ) async {
    return MakeConfig()
      ..platform = platform
      ..flavor = makeArguments?['flavor']
      ..channel = makeArguments?['channel']
      ..artifactName = makeArguments?['artifact_name']
      ..packageFormat = packageFormat
      ..outputDirectory = outputDirectory;
  }

  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
  });
}

class MakeConfig {
  late bool isInstaller = false;
  late String platform;
  String? flavor;
  String? channel;

  /// https://mustache.github.io/mustache.5.html
  String? artifactName;
  late String packageFormat;
  late Directory outputDirectory;

  String get appName => pubspec.name;
  Version get appVersion => pubspec.version!;
  String get appBuildName => appVersion.toString().split('+').first;
  String get appBuildNumber => appVersion.toString().split('+').last;

  Pubspec? _pubspec;
  Directory? _packagingDirectory;

  MakeConfig copyWith(MakeConfig makeConfig) {
    platform = makeConfig.platform;
    flavor = makeConfig.flavor;
    channel = makeConfig.channel;
    artifactName = makeConfig.artifactName;
    packageFormat = makeConfig.packageFormat;
    outputDirectory = makeConfig.outputDirectory;
    return this;
  }

  File get outputFile {
    String useArtifactName = _kArtifactName;
    if (channel != null) useArtifactName = _kArtifactNameWithChannel;
    if (artifactName != null) useArtifactName = artifactName!;

    Map<String, dynamic> variables = {
      'is_installer': isInstaller,
      'name': appName,
      'version': appVersion.toString(),
      'build_name': appBuildName,
      'build_number': appBuildNumber,
      'platform': platform,
      'flavor': flavor,
      'channel': channel,
      'ext': packageFormat,
    };

    String filename = Template(useArtifactName).renderString(variables);

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
  final Duration? duration;

  File get outputFile => makeConfig.outputFile;

  MakeResult(
    this.makeConfig, {
    this.duration,
  });
}

class MakeError extends Error {
  final String? message;

  MakeError([this.message]);

  String toString() {
    var message = this.message;
    return (message != null) ? "MakeError: $message" : "MakeError";
  }
}
