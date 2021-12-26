import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:app_package_publisher_fir/app_package_publisher_fir.dart';
import 'package:app_package_publisher_pgyer/app_package_publisher_pgyer.dart';

class FlutterAppPublisher {
  final List<AppPackagePublisher> _publishers = [
    AppPackagePublisherFir(),
    AppPackagePublisherPgyer(),
  ];

  Future<PublishResult> publish(
    File file, {
    required String target,
    Map<String, String>? environment,
    PublishProgressCallback? onPublishProgress,
  }) async {
    AppPackagePublisher publisher = _publishers.firstWhere(
      (e) => e.name == target,
    );
    return await publisher.publish(
      file,
      environment: environment,
      onPublishProgress: onPublishProgress,
    );
  }
}
