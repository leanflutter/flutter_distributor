import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class MakePkgConfig extends MakeConfig {
  MakePkgConfig({
    this.installPath,
    this.signIdentity,
  });

  factory MakePkgConfig.fromJson(Map<String, dynamic> json) {
    return MakePkgConfig(
      installPath: json['install-path'],
      signIdentity: json['sign-identity'],
    );
  }
  final String? installPath;
  final String? signIdentity;

  @override
  Map<String, dynamic> toJson() {
    return {
      'install-path': installPath,
      'sign-identity': signIdentity,
    }..removeWhere((key, value) => value == null);
  }
}

class MakePkgConfigLoader extends DefaultMakeConfigLoader {
  @override
  MakeConfig load(
    Map<String, dynamic>? arguments,
    Directory outputDirectory, {
    required Directory buildOutputDirectory,
    required List<File> buildOutputFiles,
  }) {
    final baseMakeConfig = super.load(
      arguments,
      outputDirectory,
      buildOutputDirectory: buildOutputDirectory,
      buildOutputFiles: buildOutputFiles,
    );
    final map = loadMakeConfigYaml(
      '$platform/packaging/$packageFormat/make_config.yaml',
    );
    return MakePkgConfig.fromJson(map).copyWith(baseMakeConfig);
  }
}
