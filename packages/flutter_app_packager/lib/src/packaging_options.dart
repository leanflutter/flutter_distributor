import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class PackagingOptions {
  final Directory workDirectory;
  final AppInfo appInfo;
  final String targetPlatform;
  final List<String> targets;

  Directory get binaryArchiveDir => Directory(
        '${workDirectory.path}/dist/${appInfo.name}',
      );

  Directory get outputDirectory => Directory(
        '${workDirectory.path}/dist',
      );

  PackagingOptions({
    required this.workDirectory,
    required this.appInfo,
    required this.targetPlatform,
    required this.targets,
  });
}
