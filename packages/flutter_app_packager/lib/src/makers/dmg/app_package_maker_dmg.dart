import 'dart:convert';
import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:shell_executor/shell_executor.dart';

import 'make_dmg_config.dart';

ShellExecutor get _shellExecutor => ShellExecutor.global;

class AppPackageMakerDmg extends AppPackageMaker {
  String get name => 'dmg';
  String get platform => 'macos';
  String get packageFormat => 'dmg';

  bool get isSupportedOnCurrentPlatform => Platform.isMacOS;

  @override
  Future<MakeConfig> loadMakeConfig(
    Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
  ) async {
    MakeConfig baseMakeConfig = await super.loadMakeConfig(
      outputDirectory,
      makeArguments,
    );
    final map = loadMakeConfigYaml('macos/packaging/dmg/make_config.yaml');
    return MakeDmgConfig.fromJson(map).copyWith(baseMakeConfig);
  }

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
  }) async {
    MakeDmgConfig makeConfig = await loadMakeConfig(
      outputDirectory,
      makeArguments,
    ) as MakeDmgConfig;

    Directory packagingDirectory = makeConfig.packagingDirectory;

    File appFile = appDirectory
        .listSync()
        .where((e) => e.path.endsWith('.app'))
        .map((e) => File(e.path))
        .first;

    await _shellExecutor
        .exec('cp', ['-RH', appFile.path, packagingDirectory.path]);

    await _shellExecutor
        .exec('cp', ['-RH', 'macos/packaging/dmg/.', packagingDirectory.path]);

    File makeDmgConfigJsonFile =
        File('${packagingDirectory.path}/make_config.json');
    makeDmgConfigJsonFile.writeAsStringSync(json.encode(makeConfig.toJson()));

    ProcessResult processResult = await _shellExecutor.exec('appdmg', [
      makeDmgConfigJsonFile.path,
      makeConfig.outputFile.path,
    ]);

    if (processResult.exitCode != 0) {
      throw MakeError();
    }

    packagingDirectory.deleteSync(recursive: true);

    return MakeResult(makeConfig);
  }
}
