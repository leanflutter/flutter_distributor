import 'dart:convert';
import 'dart:io';

import 'package:flutter_app_packager/src/api/make_config.dart';
import 'package:flutter_app_packager/src/api/make_result.dart';
import 'package:shell_executor/shell_executor.dart';
import 'package:yaml/yaml.dart';

export 'make_config.dart';
export 'make_error.dart';
export 'make_result.dart';

Map<String, dynamic> loadMakeConfigYaml(String path) {
  final yamlDoc = loadYaml(File(path).readAsStringSync());
  return json.decode(json.encode(yamlDoc));
}

abstract class AppPackageMaker {
  List<Command> get requirements => [];

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
    return this.platform == platform && name == target;
  }

  Future<MakeResult> make(MakeConfig config) {
    throw UnimplementedError();
  }
}
