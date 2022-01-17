import 'dart:convert';
import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

import 'publish_firebase_config.dart';

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
    Process process = await Process.start(
      'firebase',
      [
        'appdistribution:distribute',
        file.path,
        // cmd list
        ...publishConfig.toFirebaseCliDistributeArgs()
      ],
    );
    process.stdout.listen((event) {
      String msg = utf8.decoder.convert(event).trim();
      print(msg);
    });
    process.stderr.listen((event) {
      String msg = utf8.decoder.convert(event).trim();
      print(msg);
    });
    int code = await process.exitCode;
    if (code == 0) {
      return PublishResult(
        url: 'https://console.firebase.google.com/project/_/appdistribution',
      );
    } else {
      throw PublishError('$code - Upload of firebase failed');
    }
  }
}
