import 'dart:io';

import 'package:app_package_maker/src/app_info.dart';

const kDefaultPackedFilePattern = '{name}-{version}+{buildNumber}-{platform}';

class AppPackageInfo {
  final AppInfo appInfo;
  final String targetPlatform;
  // final String targetArch;
  final Directory appDirectory;
  final Directory outputDirectory;
  final String packagedFileExt;
  final String packagedFilePattern;
  final bool packagedFileIsInstaller;

  File get packagedFile {
    String filename =
        '$packagedFilePattern${packagedFileIsInstaller ? '-setup' : ''}.$packagedFileExt'
            .replaceAll('{name}', appInfo.name)
            .replaceAll('{platform}', targetPlatform)
            .replaceAll('{version}', appInfo.version)
            .replaceAll('{buildNumber}', appInfo.buildNumber);
    return File('${outputDirectory.path}/$filename');
  }

  Directory get packagingDirectory {
    return Directory(
        '${packagedFile.path.replaceAll('.$packagedFileExt', '')}');
  }

  AppPackageInfo({
    required this.appDirectory,
    required this.outputDirectory,
    required this.appInfo,
    required this.targetPlatform,
    // required this.targetArch,
    required this.packagedFileExt,
    this.packagedFilePattern = kDefaultPackedFilePattern,
    this.packagedFileIsInstaller = false,
  });
}
