import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

const kEnvAppCenterApiToken = 'APPCENTER_API_TOKEN';

class PublishAppCenterConfig extends PublishConfig {
  PublishAppCenterConfig({
    required this.apiToken,
    required this.ownerName,
    required this.appName,
    this.distributionGroup,
  });

  factory PublishAppCenterConfig.parse(
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
  ) {
    String? apiToken =
        (environment ?? Platform.environment)[kEnvAppCenterApiToken];
    if ((apiToken ?? '').isEmpty) {
      throw PublishError(
          'Missing `$kEnvAppCenterApiToken` environment variable.');
    }
    String? ownerName = publishArguments?['owner-name'];
    if ((ownerName ?? '').isEmpty) {
      throw PublishError('Missing `owner-name` arg');
    }

    String? appName = publishArguments?['app-name'];
    if ((appName ?? '').isEmpty) {
      throw PublishError('Missing `app-name` arg');
    }

    PublishAppCenterConfig publishConfig = PublishAppCenterConfig(
      apiToken: apiToken!,
      ownerName: ownerName!,
      appName: appName!,
      distributionGroup:
          publishArguments?['distribution-group'] ?? 'Collaborators',
    );
    return publishConfig;
  }

  final String apiToken;
  String ownerName;
  String appName;
  String? distributionGroup;
}
