import 'dart:io';

import 'package:app_package_parser/app_package_parser.dart';
import 'package:xml/xml.dart';

class AppPackageParserApk extends AppPackageParser {
  @override
  String get name => 'apk';

  @override
  Future<AppPackage> parse(File file) async {
    ProcessResult processResult = Process.runSync(
      'apkanalyzer',
      [
        'manifest',
        'print',
        file.path,
      ],
    );

    String xmlString = processResult.stdout;
    XmlDocument xmlDoc = XmlDocument.parse(xmlString);
    XmlElement elManifest = xmlDoc.getElement('manifest')!;
    XmlElement elApplication = elManifest.getElement('application')!;

    AppPackage appPackage = AppPackage(
      platform: 'android',
      identifier: elManifest.getAttribute('package')!,
      name: elApplication.getAttribute('android:label')!,
      version: elManifest.getAttribute('android:versionName')!,
      buildNumber: int.parse(elManifest.getAttribute('android:versionCode')!),
    );
    return appPackage;
  }
}
