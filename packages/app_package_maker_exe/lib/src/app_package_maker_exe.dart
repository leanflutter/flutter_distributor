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
  Future<MakeConfig> loadMakeConfig() async {
    final map = loadMakeConfigYaml('windows/packaging/exe/make_config.yaml');
    return MakeExeConfig.fromJson(map)
      ..isInstaller = true
      ..platform = platform
      ..packageFormat = packageFormat;
  }

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    String? flavor,
    void Function(List<int> data)? onProcessStdOut,
    void Function(List<int> data)? onProcessStdErr,
  }) async {
    MakeExeConfig makeConfig = await loadMakeConfig() as MakeExeConfig
      ..outputDirectory = outputDirectory;
    Directory packagingDirectory = makeConfig.packagingDirectory;
    copyPathSync(appDirectory.path, packagingDirectory.path);

    InnoSetupScript script = InnoSetupScript.fromMakeConfig(makeConfig);
    InnoSetupCompiler compiler = InnoSetupCompiler();

    bool compiled = await compiler.compile(
      script,
      onProcessStdErr: onProcessStdErr,
      onProcessStdOut: onProcessStdOut,
    );

    if (!compiled) {
      throw MakeError();
    }

    packagingDirectory.deleteSync(recursive: true);

    return MakeResult(makeConfig);
  }
}
