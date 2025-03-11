import 'dart:io';

import 'package:appbolt/appbolt.dart';
import 'package:collection/collection.dart';
import 'package:flutter_app_publisher/src/api/app_package_publisher.dart';
import 'package:flutter_app_publisher/src/publishers/appbolt/publish_appbolt_config.dart';
import 'package:parse_app_package/parse_app_package.dart';

extension ReleaseWithComputedProperties on Release {
  String get releaseVersion {
    String version = '$majorVersion.$minorVersion.$patchVersion';
    if (preRelease != null) {
      version = '$version-$preRelease';
    }
    version = '$version.$build';
    return version;
  }
}

class AppPackagePublisherAppBolt extends AppPackagePublisher {
  @override
  String get name => 'appbolt';

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
    FileSystemEntity fileSystemEntity, {
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    File file = fileSystemEntity as File;
    PublishAppBoltConfig publishConfig = PublishAppBoltConfig.parse(
      environment,
      publishArguments,
    );

    final client = AppBoltClient(
      baseUrl: publishConfig.apiUrl,
      apiToken: publishConfig.apiToken,
    );

    try {
      AppPackage appPackage = await parseAppPackage(file);

      String appId = publishConfig.appId;
      App app = await _getApp(client, appId);
      AppIdentifier appIdentifier = await _getAppIdentifier(
        client,
        app,
        appPackage.platform,
        appPackage.identifier,
      );
      Release release = await _getRelease(
        client,
        appId,
        appIdentifier.id,
        '${appPackage.version}+${appPackage.buildNumber}',
      );

      final result = await client.createReleaseBinary(
        appId,
        release.id,
        appIdentifierId: appIdentifier.id,
        signature: 'xxx',
      );
      if (!result.success) {
        throw PublishError('Create release failed');
      }
      ReleaseBinary releaseBinary = result.data;
      print(releaseBinary.toJson());

      return PublishResult(
        url: 'http://localhost:3000/s/$appId?releaseId=${release.id}',
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<App> _getApp(AppBoltClient client, String appId) async {
    final getAppIdentifierResult = await client.getApp(
      appId,
      includeIdentifiers: true,
    );
    return getAppIdentifierResult.data;
  }

  Future<AppIdentifier> _getAppIdentifier(
    AppBoltClient client,
    App app,
    String platform,
    String identifier,
  ) async {
    AppIdentifier? appIdentifier = app.identifiers?.firstWhereOrNull(
      (e) => e.platform == platform && e.identifier == identifier,
    );
    if (appIdentifier == null) {
      final response = await client.createAppIdentifier(
        app.id,
        identifier: identifier,
        platform: platform,
      );
      appIdentifier = response.data;
    }
    return appIdentifier;
  }

  Future<Release> _getRelease(
    AppBoltClient client,
    String appId,
    String appIdentifierId,
    String releaseVersion,
  ) async {
    final List<Release> releases = (await client.listReleases(appId)).data;

    Release? release = releases.firstWhereOrNull(
      (e) => e.releaseVersion == releaseVersion,
    );
    if (release == null) {
      final result = await client.createRelease(
        appId,
        appIdentifierId: appIdentifierId,
        releaseVersion: releaseVersion,
      );
      release = result.data;
    }
    return release;
  }
}
