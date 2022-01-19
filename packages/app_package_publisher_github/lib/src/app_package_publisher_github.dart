import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

import 'publish_github_config.dart';

class AppPackagePublisherGithub extends AppPackagePublisher {
  @override
  String get name => 'github';

  @override
  List<String> get supportedPlatforms => [
        'android',
        'ios',
        'linux',
        'macos',
        'windows',
        'web',
      ];

  @override
  Future<PublishResult> publish(
    File file, {
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    PublishGithubConfig publishConfig = PublishGithubConfig.parse(
      environment,
      publishArguments,
    );
    return PublishResult(
      url: 'https://github.com/leanflutter/flutter_distributor',
    );
  }
}
