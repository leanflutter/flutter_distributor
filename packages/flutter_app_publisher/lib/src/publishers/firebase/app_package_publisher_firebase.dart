import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:flutter_app_publisher/src/publishers/firebase/publish_firebase_config.dart';
import 'package:shell_executor/shell_executor.dart';

/// Firebase doc
/// iOS: [https://firebase.google.com/docs/app-distribution/ios/distribute-cli]
/// Android: [https://firebase.google.com/docs/app-distribution/android/distribute-cli]
class AppPackagePublisherFirebase extends AppPackagePublisher {
  String get name => 'firebase';

  @override
  List<String> get supportedPlatforms => ['android', 'ios'];

  @override
  Future<PublishResult> publish(
    File file, {
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    PublishFirebaseConfig publishConfig =
        PublishFirebaseConfig.parse(environment, publishArguments);

    // Publish to Firebase
    ProcessResult processResult = await $(
      'firebase',
      [
        'appdistribution:distribute',
        file.path,
        // cmd list
        ...publishConfig.toFirebaseCliDistributeArgs()
      ],
    );
    if (processResult.exitCode == 0) {
      return PublishResult(
        url: 'https://console.firebase.google.com/project/_/appdistribution',
      );
    } else {
      throw PublishError(
        '${processResult.exitCode} - Upload of firebase failed',
      );
    }
  }
}
