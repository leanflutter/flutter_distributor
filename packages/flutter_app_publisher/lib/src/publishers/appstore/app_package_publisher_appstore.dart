import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:shell_executor/shell_executor.dart';

import 'publish_appstore_config.dart';

ShellExecutor get _shellExecutor => ShellExecutor.global;

/// AppStore doc [https://help.apple.com/asc/appsaltool/]
class AppPackagePublisherAppStore extends AppPackagePublisher {
  String get name => 'appstore';

  @override
  List<String> get supportedPlatforms => ['ios', 'macos'];

  @override
  Future<PublishResult> publish(
    File file, {
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    // Get type
    String type = file.path.endsWith('.ipa') ? 'ios' : 'osx';
    // Get config
    PublishAppStoreConfig publishConfig =
        PublishAppStoreConfig.parse(environment, publishArguments);
    // Publish to AppStore
    ProcessResult processResult = await _shellExecutor.exec(
      'xcrun',
      [
        'altool',
        '--upload-app',
        '--file',
        file.path,
        '--type',
        type,
        // cmd list
        ...publishConfig.toAppStoreCliDistributeArgs()
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
