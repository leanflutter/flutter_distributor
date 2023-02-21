import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

const kEnvPlayStoreCredentialsFile = 'GOOGLE_APPLICATION_CREDENTIALS';

class PublishPlayStoreConfig extends PublishConfig {
  PublishPlayStoreConfig({
    required this.credentialsFile,
    required this.packageName,
  });

  factory PublishPlayStoreConfig.parse(
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
  ) {
    String? credentialsFile =
        (environment ?? Platform.environment)[kEnvPlayStoreCredentialsFile];

    if ((credentialsFile ?? '').isEmpty) {
      throw PublishError(
          'Missing `$kEnvPlayStoreCredentialsFile` environment variable.');
    }
    PublishPlayStoreConfig publishConfig = PublishPlayStoreConfig(
      credentialsFile: credentialsFile!,
      packageName: publishArguments?['package-name'],
    );
    return publishConfig;
  }
  final String credentialsFile;
  final String packageName;
}
