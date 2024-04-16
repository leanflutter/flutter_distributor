import 'dart:io';

import 'package:flutter_app_publisher/src/api/app_package_publisher.dart';
import 'package:flutter_app_publisher/src/publishers/appstore/publish_appstore_config.dart';
import 'package:shell_executor/shell_executor.dart';

/// AppStore doc [https://help.apple.com/asc/appsaltool/]
class AppPackagePublisherAppStore extends AppPackagePublisher {
  @override
  String get name => 'appstore';

  @override
  List<String> get supportedPlatforms => ['ios', 'macos'];

  @override
  Future<PublishResult> publish(
    FileSystemEntity fileSystemEntity, {
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    File file = fileSystemEntity as File;
    // Get type
    String type = file.path.endsWith('.ipa') ? 'ios' : 'osx';
    // Get config
    PublishAppStoreConfig publishConfig =
        PublishAppStoreConfig.parse(environment, publishArguments);
    // Publish to AppStore
    ProcessResult processResult = await $(
      'xcrun',
      [
        'altool',
        '--upload-app',
        '--file',
        file.path,
        '--type',
        type,
        // cmd list
        ...publishConfig.toAppStoreCliDistributeArgs(),
      ],
    );

    if (processResult.exitCode == 0) {
      return PublishResult(
        url: 'https://appstoreconnect.apple.com/apps',
      );
    } else {
      throw PublishError(
        '${processResult.exitCode} - Upload of appstore failed',
      );
    }
  }
}
