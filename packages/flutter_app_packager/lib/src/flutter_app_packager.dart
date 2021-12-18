import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:app_package_maker_aab/app_package_maker_aab.dart';
import 'package:app_package_maker_apk/app_package_maker_apk.dart';
import 'package:app_package_maker_deb/app_package_maker_deb.dart';
import 'package:app_package_maker_dmg/app_package_maker_dmg.dart';
import 'package:app_package_maker_exe/app_package_maker_exe.dart';
import 'package:app_package_maker_ipa/app_package_maker_ipa.dart';
import 'package:app_package_maker_zip/app_package_maker_zip.dart';

class FlutterAppPackager {
  final List<AppPackageMaker> _makers = [
    AppPackageMakerAab(),
    AppPackageMakerApk(),
    AppPackageMakerDeb(),
    AppPackageMakerDmg(),
    AppPackageMakerExe(),
    AppPackageMakerIpa(),
    AppPackageMakerZip('linux'),
    AppPackageMakerZip('macos'),
    AppPackageMakerZip('windows'),
  ];

  Future<MakeResult> package(
    Directory appDirectory, {
    required Directory outputDirectory,
    required String platform,
    String? flavor,
    required String target,
  }) async {
    AppPackageMaker maker = _makers.firstWhere(
      (e) => e.platform == platform && e.name == target,
    );
    return await maker.make(
      appDirectory,
      outputDirectory: outputDirectory,
      flavor: flavor,
    );
  }
}
