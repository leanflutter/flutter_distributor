import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerDirect extends AppPackageMaker {
  AppPackageMakerDirect(String platform) {
    _platform = platform;
  }

  late String _platform;

  @override
  String get name => 'direct';
  @override
  String get platform => _platform;

  @override
  Future<MakeResult> make(MakeConfig config) {
    config.buildOutputFiles.first.copySync(config.outputFile.path);
    return Future.value(resultResolver.resolve(config));
  }
}
