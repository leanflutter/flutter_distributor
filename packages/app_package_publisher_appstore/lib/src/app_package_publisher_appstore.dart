import 'dart:convert';
import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

import 'publish_appstore_config.dart';

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
    Process process = await Process.start(
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
        url: 'https://appstoreconnect.apple.com/apps',
      );
    } else {
      throw PublishError('$code - Upload of appstore failed');
    }
  }
}
