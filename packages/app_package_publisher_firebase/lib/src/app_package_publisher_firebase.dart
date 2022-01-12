import 'dart:convert';
import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

import 'publish_firebase_config.dart';

const kFirebaseAppId = 'FIREBASE_APP_ID';
const kEnvFirebaseToken = 'FIREBASE_TOKEN';

/// Firebase doc
/// iOS: [https://firebase.google.com/docs/app-distribution/ios/distribute-cli]
/// Android: [https://firebase.google.com/docs/app-distribution/android/distribute-cli]
class AppPackagePublisherFirebase extends AppPackagePublisher {
  String get name => 'firebase';

  @override
  Future<PublishResult> publish(
    File file, {
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    String? appId = (environment ?? Platform.environment)[kFirebaseAppId];
    if ((appId ?? '').isEmpty) {
      throw PublishError('Missing `$kFirebaseAppId` environment variable.');
    }

    String? token = (environment ?? Platform.environment)[kEnvFirebaseToken];

    PublishFirebaseConfig publishConfig = PublishFirebaseConfig(
      appId: appId!,
      token: token,
    );

    // Publish to Firebase
    Process process = await Process.start(
      'firebase',
      [
        'appdistribution:distribute',
        file.path,
        '--app',
        publishConfig.appId,
        // 如果有 token
        if (publishConfig.token?.isNotEmpty ?? false) ...[
          '--token',
          publishConfig.token!
        ]
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
