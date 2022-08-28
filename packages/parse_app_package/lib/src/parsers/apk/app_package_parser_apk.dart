import 'dart:io';

import 'package:app_package_parser/app_package_parser.dart';
import 'package:shell_executor/shell_executor.dart';

class AppPackageParserApk extends AppPackageParser {
  @override
  String get name => 'apk';

  @override
  Future<AppPackage> parse(File file) async {
    String? androidHome = Platform.environment['ANDROID_HOME'];
    if ((androidHome ?? '').isEmpty) {
      throw Exception('Missing `ANDROID_HOME` environment variable.');
    }

    String buildToolsDir = Directory('$androidHome/build-tools')
        .listSync()
        .firstWhere((element) => !element.path.contains(".DS_Store"))
        .path;

    ProcessResult processResult = await $(
      '$buildToolsDir/aapt',
      ['d', '--values', 'badging', file.path],
    );

    String resultString = processResult.stdout;

    RegExpMatch? regExpMatch1 =
        RegExp(r"name='([^']+)'").firstMatch(resultString);
    RegExpMatch? regExpMatch2 =
        RegExp(r"application-label:'([^']+)'").firstMatch(resultString);
    RegExpMatch? regExpMatch3 =
        RegExp(r"versionName='([^']+)").firstMatch(resultString);
    RegExpMatch? regExpMatch4 =
        RegExp(r"versionCode='(\d+)'").firstMatch(resultString);

    AppPackage appPackage = AppPackage(
      platform: 'android',
      identifier: regExpMatch1!.group(1)!,
      name: regExpMatch2!.group(1)!,
      version: regExpMatch3!.group(1)!,
      buildNumber: int.parse(regExpMatch4!.group(1)!),
    );
    return appPackage;
  }
}
