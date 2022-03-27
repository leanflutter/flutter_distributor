import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:msix/msix.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart';

import 'make_msix_config.dart';

class AppPackageMakerMsix extends AppPackageMaker {
  String get name => 'msix';
  String get platform => 'windows';
  String get packageFormat => 'msix';

  bool get isSupportedOnCurrentPlatform => Platform.isWindows;

  @override
  Future<MakeConfig> loadMakeConfig() async {
    final map = loadMakeConfigYaml('windows/packaging/msix/make_config.yaml');
    return MakeMsixConfig.fromJson(map)
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
    MakeMsixConfig makeConfig = (await loadMakeConfig() as MakeMsixConfig)
      ..outputDirectory = outputDirectory;

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
