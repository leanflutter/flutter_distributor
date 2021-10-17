import 'dart:io';

import 'app_info.dart';

abstract class AppPackageMaker {
  String get target;

  Future<String> make(
    AppInfo appInfo,
    String targetPlatform, {
    required Directory appDirectory,
    required Directory outputDirectory,
  });
}
