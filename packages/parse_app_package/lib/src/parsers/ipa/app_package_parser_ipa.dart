import 'dart:convert';
import 'dart:io';

import 'package:app_package_parser/app_package_parser.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:xml/xml.dart';

class AppPackageParserIpa extends AppPackageParser {
  @override
  String get name => 'ipa';

  _handleElem(XmlElement el) {
    switch (el.name.local) {
      case 'string':
        return el.value;
      case 'real':
        return double.parse(el.value!);
      case 'integer':
        return int.parse(el.value!);
      case 'true':
        return true;
      case 'false':
        return false;
      case 'date':
        return DateTime.parse(el.value!);
    }
  }

  @override
  Future<AppPackage> parse(File file) async {
    final ipaBytes = file.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(ipaBytes);

    String xmlString = '';
    for (final item in archive) {
      if (item.isFile && item.name.endsWith('.app/Info.plist')) {
        final data = item.content as List<int>;
        xmlString = utf8.decode(data);
        break;
      }
    }

    XmlDocument xmlDoc = XmlDocument.parse(xmlString);
    XmlElement elPlist = xmlDoc.getElement('plist')!;
    XmlElement elDict = elPlist.getElement('dict')!;

    List<String> keys = elDict.childElements
        .where((e) => e.name.local == 'key')
        .map((e) => e.value!)
        .toList();
    List<dynamic> values = elDict.childElements
        .where((e) => e.name.local != 'key')
        .map(_handleElem)
        .toList();
    Map dict = Map.fromIterables(keys, values);

    AppPackage appPackage = AppPackage(
      platform: 'ios',
      identifier: dict['CFBundleIdentifier'],
      name: dict['CFBundleDisplayName'],
      version: dict['CFBundleShortVersionString'],
      buildNumber: int.parse(dict['CFBundleVersion']),
    );
    return appPackage;
  }
}
