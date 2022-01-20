import 'dart:io';
import 'dart:typed_data';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:github/github.dart';

import 'publish_github_config.dart';

class AppPackagePublisherGithub extends AppPackagePublisher {
  var github = GitHub();

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
    try {
      // Set auth
      github.auth = Authentication.withToken(publishConfig.token);
      // Get latest release
      Release latestRelease = await github.repositories.getLatestRelease(
          RepositorySlug(publishConfig.repoOwner, publishConfig.repoName));
      // upload file
      String fileName = file.path.split('/').last;
      Uint8List fileData = await file.readAsBytes();
      List<ReleaseAsset> releaseAssetList =
          await github.repositories.uploadReleaseAssets(
        latestRelease,
        [
          CreateReleaseAsset(
            name: fileName,
            contentType: 'application/octet-stream',
            assetData: fileData,
          )
        ],
      );
      // Check ReleaseAsset
      if (releaseAssetList.isNotEmpty) {
        print(
            "releaseAssetList:${releaseAssetList.map((e) => e.toJson()).toString()}");
        return PublishResult(
          url: releaseAssetList.first.browserDownloadUrl,
        );
      } else {
        throw PublishError('ReleaseAssetList isEmpty');
      }
    } catch (error) {
      throw PublishError('${error.toString()}');
    }
  }
}
