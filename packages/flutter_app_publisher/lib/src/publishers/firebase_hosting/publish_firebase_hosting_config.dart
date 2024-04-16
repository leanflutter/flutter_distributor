import 'package:flutter_app_publisher/src/api/app_package_publisher.dart';

class PublishFirebaseHostingConfig extends PublishConfig {
  PublishFirebaseHostingConfig({
    required this.projectId,
  });

  factory PublishFirebaseHostingConfig.parse(
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
  ) {
    String? projectId = publishArguments?['project-id'];
    if ((projectId ?? '').isEmpty) {
      throw PublishError('Missing `project-id` config.');
    }

    PublishFirebaseHostingConfig publishConfig = PublishFirebaseHostingConfig(
      projectId: projectId!,
    );
    return publishConfig;
  }

  String projectId;
}
