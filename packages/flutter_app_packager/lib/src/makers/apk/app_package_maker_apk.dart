import 'package:flutter_app_packager/src/api/app_package_maker.dart';

class AppPackageMakerApk extends AppPackageMaker {
  @override
  String get name => 'apk';
  @override
  String get platform => 'android';
  @override
  String get packageFormat => 'apk';

  @override
  Future<MakeResult> make(MakeConfig config) {
    config.buildOutputFiles.first.copySync(config.outputFile.path);
    return Future.value(resultResolver.resolve(config));
  }
}
