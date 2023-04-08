import 'dart:convert';
import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:flutter_app_publisher/src/publishers/firebase_hosting/publish_firebase_hosting_config.dart';
import 'package:shell_executor/shell_executor.dart';

class AppPackagePublisherFirebaseHosting extends AppPackagePublisher {
  @override
  String get name => 'firebase-hosting';

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

    PublishFirebaseHostingConfig publishConfig =
        PublishFirebaseHostingConfig.parse(
      environment,
      publishArguments,
    );

    try {
      File firebaseRcFile = File('${directory.path}/.firebaserc');
      firebaseRcFile.createSync(recursive: true);
      firebaseRcFile.writeAsStringSync(json.encode({
        'projects': {'default': publishConfig.projectId}
      }));
      File firebaseJsonFile = File('${directory.path}/firebase.json');
      firebaseJsonFile.createSync(recursive: true);
      firebaseJsonFile.writeAsStringSync(json.encode({
        'hosting': {
          'public': '.',
          'ignore': ['firebase.json']
        }
      }));
      ProcessResult r = await $(
        'firebase',
        ['deploy'],
        workingDirectory: directory.path,
      );

      String log = r.stdout.toString();
      RegExpMatch? match =
          RegExp(r'(?<=Hosting URL: )\bhttps?:\/\/\S+\b').firstMatch(log);

      return PublishResult(
        url: match != null ? match.group(0)! : '',
      );
    } catch (error) {
      rethrow;
    }
  }
}
