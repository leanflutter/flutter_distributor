import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerAab extends AppPackageMaker {
  String get name => 'aab';
  String get platform => 'android';
  String get packageFormat => 'aab';

  @override
  Future<MakeResult> make(MakeConfig config) {
    config.buildOutputFiles.first.copySync(config.outputFile.path);
    return Future.value(resultResolver.resolve(config));
  }
}
