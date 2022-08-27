import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:path/path.dart' as p;
import 'package:shell_executor/shell_executor.dart';

import 'make_msix_config.dart';

ShellExecutor get _shellExecutor => ShellExecutor.global;

class AppPackageMakerMsix extends AppPackageMaker {
  String get name => 'msix';
  String get platform => 'windows';
  String get packageFormat => 'msix';

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
    final map = loadMakeConfigYaml('windows/packaging/msix/make_config.yaml');
    return MakeMsixConfig.fromJson(map).copyWith(baseMakeConfig);
  }

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
  }) async {
    MakeMsixConfig makeConfig = (await loadMakeConfig(
      outputDirectory,
      makeArguments,
    ) as MakeMsixConfig);

    makeConfig.output_path = makeConfig.outputFile.parent.path;
    makeConfig.output_name =
        p.basenameWithoutExtension(makeConfig.outputFile.path);
    makeConfig.build_windows = 'false';

    Map<String, dynamic> makeConfigJson = makeConfig.toJson();
    List<String> arguments = [];
    for (String key in makeConfigJson.keys) {
      dynamic value = makeConfigJson[key];
      String newKey = key.replaceAll('_', '-');
      if (newKey == 'msix-version') newKey = 'version';

      if (value is Map) {
        for (String subKey in value.keys) {
          arguments.addAll(['--$newKey', '$subKey=${value[subKey]}']);
        }
      } else {
        arguments.addAll(['--$newKey', value]);
      }
    }
    await _shellExecutor.exec(
      'flutter',
      ['pub', 'run', 'msix:create']..addAll(arguments),
    );
    return MakeResult(makeConfig);
  }
}
