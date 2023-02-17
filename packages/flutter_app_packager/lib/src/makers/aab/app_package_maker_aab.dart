import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

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

    final String pattern = [
      '${appDirectory.path}/',
      makeConfig.flavor != null
          ? '${makeConfig.flavor}${makeConfig.buildMode}/'
          : '',
      '**-${makeConfig.buildMode}.$packageFormat',
    ].join();
    List<FileSystemEntity> entities = Glob(pattern).listSync();
    if (entities.isEmpty) {
      throw MakeError('No matching package found!');
    }
    if (entities.length > 1) {
      throw MakeError('Multiple matching packages found');
    }
    File aabFile = File(entities.first.path);
    aabFile.copySync(makeConfig.outputFile.path);

    return MakeResult(makeConfig);
  }
}
