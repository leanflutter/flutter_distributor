import 'dart:io';

import 'package:flutter_app_publisher/src/api/app_package_publisher.dart';

const kEnvPlayStoreCredentialsFile = 'PLAYSTORE_CREDENTIALS';

class PublishPlayStoreConfig extends PublishConfig {
  PublishPlayStoreConfig({
    required this.credentialsFile,
    required this.packageName,
    required this.track,
  });

  factory PublishPlayStoreConfig.parse(
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
  ) {
    String? credentialsFile =
        (environment ?? Platform.environment)[kEnvPlayStoreCredentialsFile];

    if ((credentialsFile ?? '').isEmpty) {
      throw PublishError(
        'Missing `$kEnvPlayStoreCredentialsFile` environment variable.',
      );
    }
    PublishPlayStoreConfig publishConfig = PublishPlayStoreConfig(
      credentialsFile: credentialsFile!,
      packageName: publishArguments?['package-name'],
      track: publishArguments?['track'],
    );
    return publishConfig;
  }
  final String credentialsFile;
  final String packageName;
  final String track;
}
