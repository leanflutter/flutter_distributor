import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerApk extends AppPackageMaker {
  String get name => 'apk';
  String get platform => 'android';
  String get packageFormat => 'apk';

  @override
  Future<MakeConfig> loadMakeConfig() async {
    return MakeConfig()
      ..platform = 'android'
      ..packageFormat = packageFormat;
  }

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    String? jobName,
    String? flavor,
    void Function(List<int> data)? onProcessStdOut,
    void Function(List<int> data)? onProcessStdErr,
  }) async {
    MakeConfig makeConfig = await loadMakeConfig()
      ..jobName = jobName
      ..flavor = flavor
      ..outputDirectory = outputDirectory;

    File apkFile = appDirectory
        .listSync()
        .where((e) => e.path.endsWith('-release.$packageFormat'))
        .map((e) => File(e.path))
        .first;

    apkFile.copySync(makeConfig.outputFile.path);

    return MakeResult(makeConfig);
  }
}
