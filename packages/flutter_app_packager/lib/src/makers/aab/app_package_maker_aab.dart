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
    Map<String, dynamic>? makeArguments,
  }) async {
    MakeConfig makeConfig = await loadMakeConfig(
      outputDirectory,
      makeArguments,
    );

    Directory aabDirectory = Directory('${appDirectory.path}/release');
    if ((makeConfig.flavor ?? '').isNotEmpty) {
      aabDirectory = Directory(
        '${appDirectory.path}/${makeConfig.flavor}Release',
      );
    }

    File aabFile = aabDirectory
        .listSync()
        .where((e) => e.path.endsWith('-release.$packageFormat'))
        .map((e) => File(e.path))
        .first;

    aabFile.copySync(makeConfig.outputFile.path);

    return MakeResult(makeConfig);
  }
}
