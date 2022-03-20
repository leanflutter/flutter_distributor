import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:app_package_publisher_appstore/app_package_publisher_appstore.dart';
import 'package:app_package_publisher_fir/app_package_publisher_fir.dart';
import 'package:app_package_publisher_firebase/app_package_publisher_firebase.dart';
import 'package:app_package_publisher_github/app_package_publisher_github.dart';
import 'package:app_package_publisher_pgyer/app_package_publisher_pgyer.dart';
import 'package:app_package_publisher_qiniu/app_package_publisher_qiniu.dart';

class FlutterAppPublisher {
  final List<AppPackagePublisher> _publishers = [
    AppPackagePublisherAppStore(),
    AppPackagePublisherFir(),
    AppPackagePublisherFirebase(),
    AppPackagePublisherGithub(),
    AppPackagePublisherPgyer(),
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
