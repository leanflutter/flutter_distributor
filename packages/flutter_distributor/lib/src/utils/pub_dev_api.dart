import 'dart:io';

import 'package:dio/dio.dart';

class PubDevApi {
  static Future<String?> getLatestVersionFromPackage(String package) async {
    final pubSite = Platform.localeName.startsWith('zh')
        ? 'https://pub.flutter-io.cn/api/packages/$package'
        : 'https://pub.dev/api/packages/$package';
    final uri = Uri.parse(pubSite);
    try {
      final response = await Dio().get(uri.toString());
      return response.data['latest']['version'] as String?;
    } on Exception catch (err) {
      throw err;
    }
  }
}
