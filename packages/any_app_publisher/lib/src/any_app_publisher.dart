import 'dart:io';

import 'package:flutter_app_publisher/flutter_app_publisher.dart';

class AnyAppPublisher {
  final FlutterAppPublisher _flutterAppPublisher = FlutterAppPublisher();

  /// Publishes the app for the given target.
  Future<PublishResult> publish(
    FileSystemEntity fileSystemEntity, {
    required String target,
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    return _flutterAppPublisher.publish(
      fileSystemEntity,
      target: target,
      environment: environment,
      publishArguments: publishArguments,
      onPublishProgress: onPublishProgress,
    );
  }
}
