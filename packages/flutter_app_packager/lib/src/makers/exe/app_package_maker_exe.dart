import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:io/io.dart';

import 'inno_setup/inno_setup_compiler.dart';
import 'inno_setup/inno_setup_script.dart';
import 'make_exe_config.dart';

class AppPackageMakerExe extends AppPackageMaker {
  String get name => 'exe';
  String get platform => 'windows';
  String get packageFormat => 'exe';

  bool get isSupportedOnCurrentPlatform => Platform.isWindows;

  @override
  Future<MakeConfig> loadMakeConfig(
    Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
  ) async {
    MakeConfig baseMakeConfig = await super.loadMakeConfig(
      outputDirectory,
      makeArguments,
    );
    final map = loadMakeConfigYaml('windows/packaging/exe/make_config.yaml');
    return MakeExeConfig.fromJson(map).copyWith(baseMakeConfig)
      ..isInstaller = true;
  }

  Future<MakeResult> _make(
    Directory appDirectory, {
    required Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
  }) async {
    MakeExeConfig makeConfig = await loadMakeConfig(
      outputDirectory,
      makeArguments,
    ) as MakeExeConfig;

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
