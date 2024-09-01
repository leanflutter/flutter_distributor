import 'dart:io';

import 'package:flutter_app_packager/flutter_app_packager.dart';

class AnyAppPackager {
  final FlutterAppPackager _flutterAppPackager = FlutterAppPackager();

  /// Packages the app for the given platform and target.
  Future<MakeResult> package(
    String platform,
    String target,
    Map<String, dynamic>? arguments,
    Directory outputDirectory, {
    required Directory buildOutputDirectory,
    required List<File> buildOutputFiles,
  }) {
    return _flutterAppPackager.package(
      platform,
      target,
      arguments,
      outputDirectory,
      buildOutputDirectory: buildOutputDirectory,
      buildOutputFiles: buildOutputFiles,
    );
  }
}
