import 'dart:convert';
import 'dart:io';

import 'package:flutter_app_packager/src/api/app_package_maker.dart';
import 'package:flutter_app_packager/src/makers/dmg/commands/appdmg.dart';
import 'package:flutter_app_packager/src/makers/dmg/make_dmg_config.dart';
import 'package:shell_executor/shell_executor.dart';

class AppPackageMakerDmg extends AppPackageMaker {
  @override
  List<Command> get requirements => [appdmg];

  @override
  String get name => 'dmg';
  @override
  String get platform => 'macos';
  @override
  bool get isSupportedOnCurrentPlatform => Platform.isMacOS;
  @override
  String get packageFormat => 'dmg';

  @override
  MakeConfigLoader get configLoader {
    return MakeDmgConfigLoader()
      ..platform = platform
      ..packageFormat = packageFormat;
  }

  @override
  Future<MakeResult> make(MakeConfig config) async {
    Directory packagingDirectory = config.packagingDirectory;

    File appFile = config.buildOutputDirectory
        .listSync()
        .where((e) => e.path.endsWith('.app'))
        .map((e) => File(e.path))
        .first;

    try {
      await $('cp', ['-RH', '"${appFile.path}"', '"${packagingDirectory.path}"']);
      
      await $('cp', ['-RH', 'macos/packaging/dmg/.', '"${packagingDirectory.path}"']);
      
      File makeDmgConfigJsonFile = File(
        '${packagingDirectory.path}/make_config.json',
      );
      makeDmgConfigJsonFile.writeAsStringSync(json.encode(config.toJson()));

      ProcessResult processResult = await appdmg.exec([
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
