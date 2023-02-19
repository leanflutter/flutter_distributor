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
    AppPackageMakerMsix(),
    AppPackageMakerRPM(),
    AppPackageMakerZip('linux'),
    AppPackageMakerZip('macos'),
    AppPackageMakerZip('windows'),
    AppPackageMakerZip('web'),
  ];

  Future<MakeResult> package(
    String platform,
    String target,
    Map<String, dynamic>? arguments,
    Directory outputDirectory, {
    required Directory buildOutputDirectory,
    required List<File> buildOutputFiles,
  }) {
    final maker = _makers.firstWhere((e) => e.match(platform, target));
    final config = maker.configLoader.load(
      arguments,
      outputDirectory,
      buildOutputDirectory: buildOutputDirectory,
      buildOutputFiles: buildOutputFiles,
    );
    return maker.make(config);
  }
}
