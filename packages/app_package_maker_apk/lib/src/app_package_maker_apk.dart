import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerApk extends AppPackageMaker {
  String get name => 'apk';
  String get platform => 'android';
  String get packageFormat => 'apk';

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
    void Function(List<int> data)? onProcessStdOut,
    void Function(List<int> data)? onProcessStdErr,
  }) async {
    MakeConfig makeConfig = await loadMakeConfig(
      outputDirectory,
      makeArguments,
    );

    File apkFile = appDirectory
        .listSync()
        .where((e) {
          if (makeConfig.flavor != null) {
            return e.path.endsWith(
              '${makeConfig.flavor}-release.$packageFormat',
            );
          }
          return e.path.endsWith('-release.$packageFormat');
        })
        .map((e) => File(e.path))
        .first;

    apkFile.copySync(makeConfig.outputFile.path);

    return MakeResult(makeConfig);
  }
}
