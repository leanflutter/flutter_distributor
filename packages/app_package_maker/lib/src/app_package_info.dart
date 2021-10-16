import 'package:app_package_maker/src/app_info.dart';

class AppPackageInfo {
  final AppInfo appInfo;
  final String targetPlatform;
  final String format;

  String get filename {
    return '${appInfo.name}-$targetPlatform-v${appInfo.version}.$format';
  }

  AppPackageInfo({
    required this.appInfo,
    required this.targetPlatform,
    required this.format,
  });
}
