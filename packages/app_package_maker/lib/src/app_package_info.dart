import 'dart:io';

import 'package:app_package_maker/src/app_info.dart';

const kDefaultPackedFilePattern = '{name}-{version}+{buildNumber}-{platform}';

class AppPackageInfo {
  final AppInfo appInfo;
  final String targetPlatform;
  // final String targetArch;
  final Directory appDirectory;
  final Directory outputDirectory;
  final String packedFileExt;
  final String packedFilePattern;

  File get packedFile {
    String filename = '$packedFilePattern.$packedFileExt'
        .replaceAll('{name}', appInfo.name)
        .replaceAll('{platform}', targetPlatform)
        .replaceAll('{version}', appInfo.version)
        .replaceAll('{buildNumber}', appInfo.buildNumber);
    return File('${outputDirectory.path}/$filename');
  }

  Directory get packingDirectory {
    return Directory('${packedFile.path.replaceAll('.$packedFileExt', '')}');
  }

  AppPackageInfo({
    required this.appDirectory,
    required this.outputDirectory,
    required this.appInfo,
    required this.targetPlatform,
    // required this.targetArch,
    required this.packedFileExt,
    this.packedFilePattern = kDefaultPackedFilePattern,
  });
}
