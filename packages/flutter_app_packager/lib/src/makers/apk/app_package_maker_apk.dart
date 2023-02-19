import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerApk extends AppPackageMaker {
  String get name => 'apk';
  String get platform => 'android';
  String get packageFormat => 'apk';

  @override
  Future<MakeResult> make(MakeConfig config) {
    config.buildOutputFiles.first.copySync(config.outputFile.path);
    return Future.value(resultResolver.resolve(config));
  }
}
