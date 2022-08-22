import 'dart:io';

import 'makers/makers.dart';

class FlutterAppPackager {
  final List<AppPackageMaker> _makers = [
    AppPackageMakerAab(),
    AppPackageMakerApk(),
    AppPackageMakerAppImage(),
    AppPackageMakerDeb(),
    AppPackageMakerDmg(),
    AppPackageMakerExe(),
    AppPackageMakerIpa(),
    // AppPackageMakerMsix(),
    AppPackageMakerZip('linux'),
    AppPackageMakerZip('macos'),
    AppPackageMakerZip('windows'),
    AppPackageMakerZip('web'),
  ];

  Future<MakeResult> package(
    Directory appDirectory, {
    required Directory outputDirectory,
    required String platform,
    required String target,
    Map<String, dynamic>? makeArguments,
  }) async {
    AppPackageMaker maker = _makers.firstWhere(
      (e) => e.platform == platform && e.name == target,
    );
    return await maker.make(
      appDirectory,
      outputDirectory: outputDirectory,
      makeArguments: makeArguments,
    );
  }
}
