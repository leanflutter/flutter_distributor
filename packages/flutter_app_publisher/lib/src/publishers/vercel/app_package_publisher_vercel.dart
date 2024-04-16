import 'dart:convert';
import 'dart:io';

import 'package:flutter_app_publisher/src/api/app_package_publisher.dart';
import 'package:flutter_app_publisher/src/publishers/vercel/publish_vercel_config.dart';
import 'package:shell_executor/shell_executor.dart';

class AppPackagePublisherVercel extends AppPackagePublisher {
  @override
  String get name => 'vercel';

  @override
  List<String> get supportedPlatforms => ['web'];

  @override
  Future<PublishResult> publish(
    FileSystemEntity fileSystemEntity, {
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    Directory directory = fileSystemEntity as Directory;

    PublishVercelConfig publishConfig = PublishVercelConfig.parse(
      environment,
      publishArguments,
    );

    try {
      File file = File('${directory.path}/.vercel/project.json');
      file.createSync(recursive: true);
      file.writeAsStringSync(
        json.encode({
          'orgId': publishConfig.orgId,
          'projectId': publishConfig.projectId,
        }),
      );
      ProcessResult r = await $(
        'vercel',
        ['--prod'],
        workingDirectory: directory.path,
      );

      String log = r.stderr.toString();
      RegExpMatch? match =
          RegExp(r'(?<=Production: )\bhttps?:\/\/\S+\b').firstMatch(log);

      return PublishResult(
        url: match != null ? match.group(0)! : '',
      );
    } catch (error) {
      rethrow;
    }
  }
}
