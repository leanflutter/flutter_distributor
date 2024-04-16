import 'package:flutter_app_packager/src/api/app_package_maker.dart';

class AppPackageMakerAab extends AppPackageMaker {
  @override
  String get name => 'aab';
  @override
  String get platform => 'android';
  @override
  String get packageFormat => 'aab';

  @override
  Future<MakeResult> make(MakeConfig config) {
    config.buildOutputFiles.first.copySync(config.outputFile.path);
    return Future.value(resultResolver.resolve(config));
  }
}
