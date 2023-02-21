import 'dart:io';

import 'package:flutter_app_publisher/src/publishers/publishers.dart';

class FlutterAppPublisher {
  final List<AppPackagePublisher> _publishers = [
    AppPackagePublisherAppCenter(),
    AppPackagePublisherAppStore(),
    AppPackagePublisherFir(),
    AppPackagePublisherFirebase(),
    AppPackagePublisherGithub(),
    AppPackagePublisherPgyer(),
    AppPackagePublisherPlayStore(),
    AppPackagePublisherQiniu(),
  ];

  Future<PublishResult> publish(
    File file, {
    required String target,
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    AppPackagePublisher publisher = _publishers.firstWhere(
      (e) => e.name == target,
    );
    return await publisher.publish(
      file,
      environment: environment,
      publishArguments: publishArguments,
      onPublishProgress: onPublishProgress,
    );
  }
}
