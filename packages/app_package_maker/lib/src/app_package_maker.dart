import 'dart:convert';
import 'dart:io';

import 'package:app_package_maker/src/make_config.dart';
import 'package:app_package_maker/src/make_result.dart';
import 'package:yaml/yaml.dart';

Map<String, dynamic> loadMakeConfigYaml(String path) {
  final yamlDoc = loadYaml(File(path).readAsStringSync());
  return json.decode(json.encode(yamlDoc));
}

abstract class AppPackageMaker {
  String get name => throw UnimplementedError();
  String get platform => throw UnimplementedError();
  bool get isSupportedOnCurrentPlatform => true;
  String get packageFormat => throw UnimplementedError();

  MakeConfigLoader get configLoader {
    return DefaultMakeConfigLoader()
      ..platform = platform
      ..packageFormat = packageFormat;
  }

  MakeResultResolver get resultResolver => DefaultMakeResultResolver();

  bool match(String platform, [String? target]) {
    return this.platform == platform && this.name == target;
  }

  @deprecated
  Future<MakeConfig> loadMakeConfig(
    Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
  ) async {
    return MakeConfig()
      ..platform = platform
      ..buildMode = makeArguments?['build_mode']
      ..flavor = makeArguments?['flavor']
      ..channel = makeArguments?['channel']
      ..artifactName = makeArguments?['artifact_name']
      ..packageFormat = packageFormat
      ..outputDirectory = outputDirectory;
  }

  Future<MakeResult> make(MakeConfig config) {
    throw UnimplementedError();
  }
}
