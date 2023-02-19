import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerIpa extends AppPackageMaker {
  String get name => 'ipa';
  String get platform => 'ios';
  String get packageFormat => 'ipa';

  @override
  Future<MakeResult> make(MakeConfig config) {
    File pkgFile = config.buildOutputFiles.first;
    pkgFile.copySync(config.outputFile.path);
    return Future.value(resultResolver.resolve(config));
  }
}
