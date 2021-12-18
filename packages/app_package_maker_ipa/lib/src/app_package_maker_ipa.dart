import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerIpa extends AppPackageMaker {
  String get name => 'ipa';
  String get platform => 'ios';
  String get packageFormat => 'ipa';

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    String? flavor,
  }) async {
    MakeConfig makeConfig = await loadMakeConfig()
      ..flavor = flavor
      ..outputDirectory = outputDirectory;

    File ipaFile = appDirectory
        .listSync()
        .where((e) => e.path.endsWith('.$packageFormat'))
        .map((e) => File(e.path))
        .first;

    ipaFile.copySync(makeConfig.outputFile.path);

    return MakeResult(makeConfig);
  }
}
