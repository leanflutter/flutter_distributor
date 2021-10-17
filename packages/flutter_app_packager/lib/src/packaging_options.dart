import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class PackagingOptions {
  final AppInfo appInfo;
  final String targetPlatform;
  final String packagedFilePattern;
  final List<String> targets;

  Directory get appDirectory =>
      Directory('${outputDirectory.path}/${appInfo.name}');
  Directory get outputDirectory =>
      Directory('dist/v${appInfo.version}+${appInfo.buildNumber}');

  PackagingOptions({
    required this.appInfo,
    required this.targetPlatform,
    this.packagedFilePattern = kDefaultPackedFilePattern,
    required this.targets,
  });
}
