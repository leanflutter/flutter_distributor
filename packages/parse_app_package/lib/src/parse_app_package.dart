import 'dart:io';

import 'package:app_package_parser/app_package_parser.dart';
import 'package:app_package_parser_apk/app_package_parser_apk.dart';
import 'package:app_package_parser_ipa/app_package_parser_ipa.dart';

final List<AppPackageParser> _parsers = [
  AppPackageParserApk(),
  AppPackageParserIpa(),
];

Future<AppPackage> parseAppPackage(File file) {
  AppPackageParser parser = _parsers.firstWhere(
    (e) => file.path.endsWith('.${e.name}'),
  );
  return parser.parse(file);
}
