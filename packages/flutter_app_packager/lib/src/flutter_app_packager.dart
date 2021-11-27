import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:app_package_maker_aab/app_package_maker_aab.dart';
import 'package:app_package_maker_apk/app_package_maker_apk.dart';
import 'package:app_package_maker_deb/app_package_maker_deb.dart';
import 'package:app_package_maker_dmg/app_package_maker_dmg.dart';
import 'package:app_package_maker_exe/app_package_maker_exe.dart';
import 'package:app_package_maker_zip/app_package_maker_zip.dart';

class FlutterAppPackager {
  final List<AppPackageMaker> _makers = [
    AppPackageMakerAab(),
    AppPackageMakerApk(),
    AppPackageMakerDeb(),
    AppPackageMakerDmg(),
    AppPackageMakerExe(),
    AppPackageMakerZip(),
  ];

  Future<MakeResult> package({
    required String appName,
    required String appVersion,
    required Directory appDirectory,
    required String targetPlatform,
    required String target,
    required Directory outputDirectory,
  }) async {
    AppPackageMaker maker = _makers.firstWhere(
      (e) => e.name == target,
    );
    MakeConfig makeConfig = MakeConfig(
      appName: appName,
      appBuildNumber: int.parse(appVersion.split('+').last),
      appVersion: appVersion.split('+').first,
      outputDirectory: outputDirectory,
    );
    MakeResult makeResult = await maker.make(
      appDirectory: appDirectory,
      targetPlatform: targetPlatform,
      makeConfig: makeConfig,
    );
    return makeResult;
  }
}
