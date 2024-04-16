import 'dart:io';

import 'package:flutter_app_packager/src/api/app_package_maker.dart';
import 'package:flutter_app_packager/src/makers/pkg/make_pkg_config.dart';
import 'package:shell_executor/shell_executor.dart';

class AppPackageMakerPkg extends AppPackageMaker {
  @override
  String get name => 'pkg';
  @override
  String get platform => 'macos';
  @override
  String get packageFormat => 'pkg';

  @override
  MakeConfigLoader get configLoader {
    return MakePkgConfigLoader()
      ..platform = platform
      ..packageFormat = packageFormat;
  }

  @override
  Future<MakeResult> make(MakeConfig config) async {
    MakePkgConfig makeConfig = config as MakePkgConfig;
    File appFile = config.buildOutputFiles.first;

    File outputFile = config.outputFile;
    File unsignedPkgFile = File(
      outputFile.path.replaceFirst(
        '.$packageFormat',
        '-unsigned.$packageFormat',
      ),
    );

    await $('xcrun', [
      'productbuild',
      '--root',
      appFile.path,
      makeConfig.installPath ?? '/Applications/',
      unsignedPkgFile.path,
    ]);
    if (makeConfig.signIdentity != null) {
      await $('xcrun', [
        'productsign',
        '--sign',
        makeConfig.signIdentity!,
        unsignedPkgFile.path,
        outputFile.path,
      ]);
      unsignedPkgFile.deleteSync();
    } else {
      unsignedPkgFile.renameSync(outputFile.path);
    }
    return Future.value(resultResolver.resolve(config));
  }
}
