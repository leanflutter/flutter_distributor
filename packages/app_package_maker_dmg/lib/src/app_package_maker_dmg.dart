import 'dart:convert';
import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

import 'make_dmg_config.dart';

class AppPackageMakerDmg extends AppPackageMaker {
  String get name => 'dmg';
  String get platform => 'macos';
  String get packageFormat => 'dmg';

  bool get isSupportedOnCurrentPlatform => Platform.isMacOS;

  @override
  Future<MakeConfig> loadMakeConfig() async {
    final map = loadMakeConfigYaml('macos/packaging/dmg/make_config.yaml');
    return MakeDmgConfig.fromJson(map)
      ..platform = 'macos'
      ..packageFormat = packageFormat;
  }

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    String? flavor,
  }) async {
    MakeDmgConfig makeConfig = (await loadMakeConfig() as MakeDmgConfig)
      ..outputDirectory = outputDirectory;
    Directory packagingDirectory = makeConfig.packagingDirectory;

    File appFile = appDirectory
        .listSync()
        .where((e) => e.path.endsWith('.app'))
        .map((e) => File(e.path))
        .first;

    await exec('cp', ['-RH', appFile.path, packagingDirectory.path]);
    await exec('cp', ['-RH', 'macos/packaging/dmg/.', packagingDirectory.path]);

    File makeDmgConfigJsonFile =
        File('${packagingDirectory.path}/make_config.json');
    makeDmgConfigJsonFile.writeAsStringSync(json.encode(makeConfig.toJson()));

    await exec('appdmg', [
      makeDmgConfigJsonFile.path,
      makeConfig.outputFile.path,
    ]);

    packagingDirectory.deleteSync(recursive: true);

    return MakeResult(makeConfig);
  }
}
