import 'dart:io';
import 'dart:typed_data';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:dio/dio.dart';
import 'package:shell_executor/shell_executor.dart';

import 'publish_appcenter_config.dart';

const _kUploadDomain = "https://file.appcenter.ms/upload";

class AppPackagePublisherAppCenter extends AppPackagePublisher {
  final Dio _dio = Dio();

  @override
  String get name => 'appcenter';

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
    PublishAppCenterConfig publishConfig = PublishAppCenterConfig.parse(
      environment,
      publishArguments,
    );
    _dio.options = BaseOptions(
      baseUrl: 'https://api.appcenter.ms/v0.1',
      headers: {
        'X-API-Token': publishConfig.apiToken,
      },
    );
    // _dio.interceptors.add(LogInterceptor(
    //   requestBody: true,
    //   responseBody: true,
    // ));

    try {
      // Creating release (1/7)
      Map<String, dynamic> release = await _createRelease(
        ownerName: publishConfig.ownerName,
        appName: publishConfig.appName,
      );
      String releasesId = release['id'];
      String packageAssetId = release['package_asset_id'];
      String urlEncodedToken = release['url_encoded_token'];

      // Creating metadata (2/7)
      String fileName = file.path.split('/').last;
      String contentType = "application/octet-stream";
      if (fileName.endsWith('.apk')) {
        contentType = 'application/vnd.android.package-archive';
      }
      Map<String, dynamic> metadata = await _createMetadata(
        fileName: fileName,
        fileSize: file.lengthSync(),
        packageAssetId: packageAssetId,
        urlEncodedToken: urlEncodedToken,
        contentType: contentType,
      );

      int chunkSize = metadata['chunk_size'];

      // Uploading chunked binary (3/7)
      await _uploadingChunkedBinary(
        file: file,
        packageAssetId: packageAssetId,
        urlEncodedToken: urlEncodedToken,
        contentType: contentType,
        chunkSize: chunkSize,
        onPublishProgress: onPublishProgress,
      );

      // Finalising upload (4/7)
      await _finalisingUpload(
        packageAssetId: packageAssetId,
        urlEncodedToken: urlEncodedToken,
      );

      // Commit release (5/7)
      await _commitRelease(
        ownerName: publishConfig.ownerName,
        appName: publishConfig.appName,
        releasesId: releasesId,
      );

      // Polling for release id (6/7)
      int releaseDistinctId = await _pollingForReleaseDistinctId(
        ownerName: publishConfig.ownerName,
        appName: publishConfig.appName,
        releasesId: releasesId,
      );

      // Applying destination to release (7/7)
      await _applyingDestinationToRelease(
        ownerName: publishConfig.ownerName,
        appName: publishConfig.appName,
        releaseDistinctId: releaseDistinctId,
        distributionGroup: publishConfig.distributionGroup!,
      );
    } catch (error) {
      throw error;
    }

    return PublishResult(
      url:
          'https://install.appcenter.ms/users/${publishConfig.ownerName}/apps/${publishConfig.appName}/distribution_groups/${publishConfig.distributionGroup}',
    );
  }

  Future<Map<String, dynamic>> _createRelease({
    required String ownerName,
    required String appName,
  }) async {
    final response = await _dio.post(
      '/apps/${ownerName}/${appName}/uploads/releases',
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> _createMetadata({
    required String fileName,
    required int fileSize,
    required String packageAssetId,
    required String urlEncodedToken,
    required String contentType,
  }) async {
    final response = await _dio.post(
        "$_kUploadDomain/set_metadata/$packageAssetId?file_name=$fileName&file_size=$fileSize&token=$urlEncodedToken&content_type=$contentType");
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> _uploadingChunkedBinary({
    required File file,
    required String packageAssetId,
    required String urlEncodedToken,
    required String contentType,
    required int chunkSize,
    PublishProgressCallback? onPublishProgress,
  }) async {
    String chunkingPath = '${file.path}_chunking/';
    await $('rm', ['-rf', chunkingPath]);
    await $('mkdir', [chunkingPath]);
    await $(
      'split',
      ['-b', '$chunkSize', file.path, chunkingPath],
    );

    Directory chunkingDir = Directory(chunkingPath);
    List<FileSystemEntity> entityList = chunkingDir.listSync();
    entityList.sort((a, b) => a.path.compareTo(b.path));

    for (var i = 0; i < entityList.length; i++) {
      FileSystemEntity entity = entityList[i];
      Uint8List fileData = File(entity.path).readAsBytesSync();
      int contentLength = fileData.length;
      await _dio.post(
        '$_kUploadDomain/upload_chunk/$packageAssetId?token=$urlEncodedToken&block_number=${i + 1}',
        data: Stream.fromIterable(fileData.map((e) => [e])),
        options: Options(headers: {
          Headers.contentLengthHeader: contentLength,
          Headers.contentTypeHeader: contentType,
        }),
        onSendProgress: (sent, total) {
          if (onPublishProgress != null) {
            onPublishProgress((i * chunkSize) + sent, file.lengthSync());
          }
        },
      );
    }
    await $('rm', ['-rf', chunkingPath]);
    return Map<String, dynamic>.from({});
  }

  Future<Map<String, dynamic>> _finalisingUpload({
    required String packageAssetId,
    required String urlEncodedToken,
  }) async {
    final response = await _dio.post(
      '$_kUploadDomain/finished/$packageAssetId?token=$urlEncodedToken',
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> _commitRelease({
    required String ownerName,
    required String appName,
    required String releasesId,
  }) async {
    final response = await _dio.patch(
      '/apps/${ownerName}/${appName}/uploads/releases/$releasesId',
      data: {
        "upload_status": "uploadFinished",
        "id": releasesId,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<int> _pollingForReleaseDistinctId({
    required String ownerName,
    required String appName,
    required String releasesId,
  }) async {
    int? releaseDistinctId = null;
    int counter = 0;
    int maxPollAttempts = 15;

    while (releaseDistinctId == null && counter < maxPollAttempts) {
      try {
        final response = await _dio.get(
          '/apps/${ownerName}/${appName}/uploads/releases/$releasesId',
        );
        releaseDistinctId = response.data['release_distinct_id'];
      } catch (error) {
        // skip
      }
      counter = counter + 1;
      await Future.delayed(Duration(seconds: 3));
    }

    if (releaseDistinctId == null) {
      throw PublishError("Failed to find release from appcenter");
    }
    return releaseDistinctId;
  }

  Future<Map<String, dynamic>> _applyingDestinationToRelease({
    required String ownerName,
    required String appName,
    required int releaseDistinctId,
    required String distributionGroup,
  }) async {
    final response = await _dio.patch(
      '/apps/${ownerName}/${appName}/releases/$releaseDistinctId',
      data: {
        "destinations": [
          {'name': distributionGroup}
        ],
      },
    );

    return Map<String, dynamic>.from(response.data);
  }
}
