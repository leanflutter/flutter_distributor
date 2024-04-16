import 'dart:io';

import 'package:flutter_app_packager/src/api/app_package_maker.dart';
import 'package:flutter_app_packager/src/makers/msix/make_msix_config.dart';
import 'package:msix/msix.dart';
import 'package:path/path.dart' as p;

class AppPackageMakerMsix extends AppPackageMaker {
  @override
  String get name => 'msix';
  @override
  String get platform => 'windows';
  @override
  bool get isSupportedOnCurrentPlatform => Platform.isWindows;
  @override
  String get packageFormat => 'msix';

  @override
  MakeConfigLoader get configLoader {
    return MakeMsixConfigLoader()
      ..platform = platform
      ..packageFormat = packageFormat;
  }

  @override
  Future<MakeResult> make(MakeConfig config) {
    return _make(
      config.buildOutputDirectory,
      outputDirectory: config.outputDirectory,
      makeConfig: config as MakeMsixConfig,
    );
  }

  Future<MakeResult> _make(
    Directory appDirectory, {
    required Directory outputDirectory,
    required MakeMsixConfig makeConfig,
  }) async {
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
    await Msix(arguments).create();
    return MakeResult(makeConfig);
  }
}
