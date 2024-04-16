import 'package:flutter_app_publisher/src/api/app_package_publisher.dart';

class PublishVercelConfig extends PublishConfig {
  PublishVercelConfig({
    required this.orgId,
    required this.projectId,
  });

  factory PublishVercelConfig.parse(
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
  ) {
    String? orgId = publishArguments?['org-id'];
    if ((orgId ?? '').isEmpty) {
      throw PublishError('Missing `org-id` config.');
    }

    String? projectId = publishArguments?['project-id'];
    if ((projectId ?? '').isEmpty) {
      throw PublishError('Missing `project-id` config.');
    }

    PublishVercelConfig publishConfig = PublishVercelConfig(
      orgId: orgId!,
      projectId: projectId!,
    );
    return publishConfig;
  }

  String orgId;
  String projectId;
}
