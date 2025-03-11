import 'dart:io';

import 'package:flutter_app_publisher/src/api/app_package_publisher.dart';

const kEnvAppBoltApiToken = 'APPBOLT_API_TOKEN';

class PublishAppBoltConfig extends PublishConfig {
  PublishAppBoltConfig({
    required this.apiUrl,
    required this.apiToken,
    required this.appId,
  });

  factory PublishAppBoltConfig.parse(
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
  ) {
    String? apiToken =
        (environment ?? Platform.environment)[kEnvAppBoltApiToken];
    if ((apiToken ?? '').isEmpty) {
      throw PublishError(
        'Missing `$kEnvAppBoltApiToken` environment variable.',
      );
    }

    String? apiUrl = publishArguments?['api-url'];
    if ((apiUrl ?? '').isEmpty) {
      throw PublishError('Missing `api-url` arg');
    }

    String? appId = publishArguments?['app-id'];
    if ((appId ?? '').isEmpty) {
      throw PublishError('Missing `app-id` arg');
    }

    return PublishAppBoltConfig(
      apiUrl: apiUrl!,
      apiToken: apiToken!,
      appId: appId!,
    );
  }

  final String apiUrl;
  final String apiToken;
  final String appId;
}
