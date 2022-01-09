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
    void Function(List<int> data)? onProcessStdOut,
    void Function(List<int> data)? onProcessStdErr,
  }) async {
    MakeDmgConfig makeConfig = (await loadMakeConfig() as MakeDmgConfig)
      ..outputDirectory = outputDirectory;
    Directory packagingDirectory = makeConfig.packagingDirectory;

    File appFile = appDirectory
        .listSync()
        .where((e) => e.path.endsWith('.app'))
        .map((e) => File(e.path))
        .first;

    Process process1 = await Process.start(
        'cp', ['-RH', appFile.path, packagingDirectory.path]);
    process1.stdout.listen(onProcessStdOut);
    process1.stderr.listen(onProcessStdErr);
    await process1.exitCode;

    Process process2 = await Process.start(
        'cp', ['-RH', 'macos/packaging/dmg/.', packagingDirectory.path]);
    process2.stdout.listen(onProcessStdOut);
    process2.stderr.listen(onProcessStdErr);
    await process2.exitCode;

    File makeDmgConfigJsonFile =
        File('${packagingDirectory.path}/make_config.json');
    makeDmgConfigJsonFile.writeAsStringSync(json.encode(makeConfig.toJson()));

    Process process3 = await Process.start('appdmg', [
      makeDmgConfigJsonFile.path,
      makeConfig.outputFile.path,
    ]);
    process3.stdout.listen(onProcessStdOut);
    process3.stderr.listen(onProcessStdErr);

    int exitCode = await process3.exitCode;
    if (exitCode != 0) {
      throw MakeError();
    }

    packagingDirectory.deleteSync(recursive: true);

    return MakeResult(makeConfig);
  }
}
