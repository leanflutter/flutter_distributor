import 'dart:convert';
import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:flutter_app_packager/src/makers/dmg/make_dmg_config.dart';
import 'package:shell_executor/shell_executor.dart';

class AppPackageMakerDmg extends AppPackageMaker {
  String get name => 'dmg';
  String get platform => 'macos';
  bool get isSupportedOnCurrentPlatform => Platform.isMacOS;
  String get packageFormat => 'dmg';

  MakeConfigLoader get configLoader {
    return MakeDmgConfigLoader()
      ..platform = platform
      ..packageFormat = packageFormat;
  }

  Future<MakeResult> make(MakeConfig config) async {
    Directory packagingDirectory = config.packagingDirectory;

    File appFile = config.buildOutputDirectory
        .listSync()
        .where((e) => e.path.endsWith('.app'))
        .map((e) => File(e.path))
        .first;

    try {
      await $('cp', ['-RH', appFile.path, packagingDirectory.path]);

      await $('cp', ['-RH', 'macos/packaging/dmg/.', packagingDirectory.path]);

      File makeDmgConfigJsonFile = File(
        '${packagingDirectory.path}/make_config.json',
      );
      makeDmgConfigJsonFile.writeAsStringSync(json.encode(config.toJson()));

      ProcessResult processResult = await $('appdmg', [
        makeDmgConfigJsonFile.path,
        config.outputFile.path,
      ]);

      if (processResult.exitCode != 0) {
        throw MakeError();
      }
    } catch (error) {
      rethrow;
    } finally {
      packagingDirectory.deleteSync(recursive: true);
    }

    return resultResolver.resolve(config);
  }
}
