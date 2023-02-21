import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:flutter_app_packager/src/makers/exe/inno_setup/inno_setup_compiler.dart';
import 'package:flutter_app_packager/src/makers/exe/inno_setup/inno_setup_script.dart';
import 'package:flutter_app_packager/src/makers/exe/make_exe_config.dart';
import 'package:io/io.dart';

class AppPackageMakerExe extends AppPackageMaker {
  String get name => 'exe';
  String get platform => 'windows';
  bool get isSupportedOnCurrentPlatform => Platform.isWindows;
  String get packageFormat => 'exe';

  MakeConfigLoader get configLoader {
    return MakeExeConfigLoader()
      ..platform = platform
      ..packageFormat = packageFormat;
  }

  @override
  Future<MakeResult> make(MakeConfig config) {
    return _make(
      config.buildOutputDirectory,
      outputDirectory: config.outputDirectory,
      makeConfig: config as MakeExeConfig,
    );
  }

  Future<MakeResult> _make(
    Directory appDirectory, {
    required Directory outputDirectory,
    required MakeExeConfig makeConfig,
  }) async {
    Directory packagingDirectory = makeConfig.packagingDirectory;
    copyPathSync(appDirectory.path, packagingDirectory.path);

    InnoSetupScript script = InnoSetupScript.fromMakeConfig(makeConfig);
    InnoSetupCompiler compiler = InnoSetupCompiler();

    bool compiled = await compiler.compile(script);

    if (!compiled) {
      throw MakeError();
    }

    packagingDirectory.deleteSync(recursive: true);

    return MakeResult(makeConfig);
  }
}
