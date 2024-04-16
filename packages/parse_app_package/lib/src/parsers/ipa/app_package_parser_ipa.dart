import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:parse_app_package/src/api/app_package_parser.dart';
import 'package:plist_parser/plist_parser.dart';

class AppPackageParserIpa extends AppPackageParser {
  @override
  String get name => 'ipa';

  @override
  Future<AppPackage> parse(File file) async {
    final ipaBytes = file.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(ipaBytes);
    Map<dynamic, dynamic>? result;
    for (final item in archive) {
      if (item.isFile && item.name.endsWith('.app/Info.plist')) {
        final data = item.content;
        result = PlistParser().parseBytes(data);
        break;
      }
    }
    if (result == null) throw Exception('Can\'t parse .ipa file.');
    return AppPackage(
      platform: 'ios',
      identifier: result['CFBundleIdentifier'],
      name: result['CFBundleDisplayName'] ?? result['CFBundleName'],
      version: result['CFBundleShortVersionString'],
      buildNumber: int.parse(result['CFBundleVersion']),
    );
  }
}
