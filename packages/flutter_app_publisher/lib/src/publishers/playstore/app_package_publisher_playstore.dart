import 'dart:convert';
import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:flutter_app_publisher/src/publishers/playstore/publish_playstore_config.dart';
import 'package:googleapis/androidpublisher/v3.dart';
import 'package:googleapis_auth/auth_io.dart';

class AppPackagePublisherPlayStore extends AppPackagePublisher {
  @override
  String get name => 'playstore';

  @override
  List<String> get supportedPlatforms => ['android'];

  @override
  Future<PublishResult> publish(
    File file, {
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    PublishPlayStoreConfig publishConfig = PublishPlayStoreConfig.parse(
      environment,
      publishArguments,
    );

    String jsonString = File(publishConfig.credentialsFile).readAsStringSync();
    ServiceAccountCredentials serviceAccountCredentials =
        ServiceAccountCredentials.fromJson(json.decode(jsonString));

    final client = await clientViaServiceAccount(
      serviceAccountCredentials,
      [
        AndroidPublisherApi.androidpublisherScope,
      ],
    );

    final AndroidPublisherApi publisherApi = AndroidPublisherApi(client);

    AppEdit appEdit = await publisherApi.edits.insert(
      AppEdit(),
      publishConfig.packageName,
    );
    Media uploadMedia = Media(file.openRead(), file.lengthSync());

    await publisherApi.edits.bundles.upload(
      publishConfig.packageName,
      appEdit.id!,
      uploadMedia: uploadMedia,
    );

    await publisherApi.edits.commit(
      publishConfig.packageName,
      appEdit.id!,
    );

    return PublishResult(
      url: '',
    );
  }
}
