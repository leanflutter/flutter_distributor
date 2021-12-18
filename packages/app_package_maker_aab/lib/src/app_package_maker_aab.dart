import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerAab extends AppPackageMaker {
  String get name => 'aab';
  String get platform => 'android';
  String get packageFormat => 'aab';

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    String? flavor,
  }) async {
    MakeConfig makeConfig = await loadMakeConfig()
      ..flavor = flavor
      ..outputDirectory = outputDirectory;

    File aabFile = appDirectory
        .listSync()
        .where((e) => e.path.endsWith('${flavor ?? ''}-release.$packageFormat'))
        .map((e) => File(e.path))
        .first;

    aabFile.copySync(makeConfig.outputFile.path);

    return MakeResult(makeConfig);
  }
}
