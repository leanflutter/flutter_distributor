import 'dart:io';

const kDefaultPackageNaming = '{name}-{version}+{buildNumber}-{platform}';

abstract class AppPackageMaker {
  String get name => throw UnimplementedError();
  String get packageFormat => throw UnimplementedError();

  bool get isSupportedOnCurrentPlatform => true;

  Future<MakeResult> make({
    required Directory appDirectory,
    required String targetPlatform,
    required MakeConfig makeConfig,
  });
}

class MakeConfig {
  final String appName;
  final String appVersion;
  final int appBuildNumber;
  final Directory outputDirectory;

  MakeConfig({
    required this.appName,
    required this.appVersion,
    required this.appBuildNumber,
    required this.outputDirectory,
  });
}

class MakeResult {
  final MakeConfig makeConfig;
  final bool isInstaller;
  final String targetArch;
  final String targetPlatform;
  final String packageFormat;
  final String packageNaming;

  File get outputPackageFile {
    String filename =
        '$packageNaming${isInstaller ? '-setup' : ''}.$packageFormat'
            .replaceAll('{name}', makeConfig.appName)
            .replaceAll('{platform}', targetPlatform)
            .replaceAll('{version}', makeConfig.appVersion)
            .replaceAll('{buildNumber}', '${makeConfig.appBuildNumber}');
    return File('${makeConfig.outputDirectory.path}/$filename');
  }

  Directory get packagingDirectory {
    return Directory(
      '${outputPackageFile.path.replaceAll('.$packageFormat', '')}',
    );
  }

  MakeResult({
    this.isInstaller = false,
    required this.makeConfig,
    this.targetArch = '',
    required this.targetPlatform,
    required this.packageFormat,
    this.packageNaming = kDefaultPackageNaming,
  });
}
