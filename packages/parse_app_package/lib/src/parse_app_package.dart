import 'dart:io';

import 'parsers/parsers.dart';

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
