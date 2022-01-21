import 'dart:io';
import 'dart:typed_data';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:dio/dio.dart';

import 'publish_github_config.dart';

class AppPackagePublisherGithub extends AppPackagePublisher {
  final Dio _dio = Dio();

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
    // Set auth
    _dio.options = BaseOptions(headers: {
      'Authorization': 'token ${publishConfig.token}',
    });

    // Get uploadUrl
    String? uploadUrl;
    if (publishConfig.releaseName?.isEmpty ?? true) {
      uploadUrl = await getUploadurlByLatestRelease(publishConfig);
    } else {
      uploadUrl = await getUploadurlByReleaseName(publishConfig);
    }
    if (uploadUrl?.isEmpty ?? true) {
      throw PublishError('Upload url isEmpty');
    }
    // Upload file
    String browserDownloadUrl =
        await uploadReleaseAsset(file, uploadUrl!, onPublishProgress);
    return PublishResult(
      url: browserDownloadUrl,
    );
  }

  /// Get uploadUrl by releaseName
  Future<String?> getUploadurlByReleaseName(
      PublishGithubConfig publishConfig) async {
    assert(publishConfig.releaseName?.isEmpty ?? true);
    Response resp = await _dio.get(
        'https://api.github.com/repos/${publishConfig.repoOwner}/${publishConfig.repoName}/releases');
    List relist = (resp.data as List?) ?? [];
    var release = relist.firstWhere(
      (item) => item['name'] == publishConfig.releaseName,
      orElse: () => {},
    );
    return release?['upload_url'];
  }

  /// Get uploadUrl by latest release
  Future<String?> getUploadurlByLatestRelease(
      PublishGithubConfig publishConfig) async {
    Response resp = await _dio.get(
        'https://api.github.com/repos/${publishConfig.repoOwner}/${publishConfig.repoName}/releases/latest');
    return resp.data?['upload_url'];
  }

  /// Upload Release Asset
  Future<String> uploadReleaseAsset(File file, String uploadUrl,
      PublishProgressCallback? onPublishProgress) async {
    // Fromat uploadUrl
    uploadUrl = uploadUrl.split('{').first;
    String fileName = file.path.split('/').last;
    Uint8List fileData = await file.readAsBytes();
    String url = '$uploadUrl?name=$fileName';
    // dio upload
    _dio.options.headers
        .putIfAbsent('Content-Type', () => 'application/octet-stream');
    String? browserDownloadUrl;
    try {
      Response resp = await _dio.post(
        url,
        data: fileData,
        onSendProgress: (int sent, int total) {
          if (onPublishProgress != null) {
            onPublishProgress(sent, total);
          }
        },
      );
      browserDownloadUrl = resp.data?['browser_download_url'];
    } catch (e) {
      throw PublishError(e.toString());
    }
    // Check release asset
    if (browserDownloadUrl?.isEmpty ?? true) {
      throw PublishError('Release asset exist [$fileName]');
    }
    return browserDownloadUrl!;
  }
}
