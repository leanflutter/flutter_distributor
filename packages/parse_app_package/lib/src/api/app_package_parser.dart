import 'dart:io';

abstract class AppPackageParser {
  String get name => throw UnimplementedError();

  bool get isSupportedOnCurrentPlatform => true;

  Future<AppPackage> parse(File file);
}

class AppPackage {
  AppPackage({
    required this.platform,
    required this.identifier,
    required this.name,
    required this.version,
    required this.buildNumber,
  });

  final String platform;
  final String identifier;
  final String name;
  final String version;
  final int buildNumber;

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'identifier': identifier,
      'name': name,
      'version': version,
      'buildNumber': buildNumber,
    }..removeWhere((key, value) => value == null);
  }
}
