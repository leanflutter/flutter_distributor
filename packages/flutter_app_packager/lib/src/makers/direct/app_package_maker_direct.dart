import 'package:flutter_app_packager/src/api/app_package_maker.dart';
import 'package:io/io.dart';

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
  String get packageFormat => '';

  @override
  Future<MakeResult> make(MakeConfig config) {
    copyPathSync(config.buildOutputDirectory.path, config.outputArtifactPath);
    return Future.value(resultResolver.resolve(config));
  }
}
