import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app_publisher/src/publishers/fir/publish_fir_config.dart';
import 'package:parse_app_package/parse_app_package.dart';

const kEnvFirApiToken = 'FIR_API_TOKEN';

class AppPackagePublisherFir extends AppPackagePublisher {
  @override
  String get name => 'fir';

  @override
  List<String> get supportedPlatforms => ['android', 'ios'];

  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'http://api.bq04.com'),
  );

  Future<String> _uploadAppBinary(
    File file,
    AppPackage appPackage, {
    required String key,
    required String token,
    required String uploadUrl,
    PublishProgressCallback? onPublishProgress,
  }) async {
    FormData formData = FormData.fromMap({
      'key': key,
      'token': token,
      'file': await MultipartFile.fromFile(file.path),
      'x:name': appPackage.name,
      'x:version': appPackage.version,
      'x:build': appPackage.buildNumber,
    });

    final response = await _dio.post(
      uploadUrl,
      data: formData,
      onSendProgress: (int sent, int total) {
        if (onPublishProgress != null) {
          onPublishProgress(sent, total);
        }
      },
    );
    return response.data['release_id'];
  }

  @override
  Future<PublishResult> publish(
    FileSystemEntity fileSystemEntity, {
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    File file = fileSystemEntity as File;
    String? apiToken = (environment ?? Platform.environment)[kEnvFirApiToken];
    if ((apiToken ?? '').isEmpty) {
      throw PublishError('Missing `$kEnvFirApiToken` environment variable.');
    }

    PublishFirConfig publishConfig = PublishFirConfig(
      apiToken: apiToken!,
    );

    try {
      AppPackage appPackage = await parseAppPackage(file);

      final response = await _dio.post(
        '/apps',
        data: {
          'type': appPackage.platform,
          'bundle_id': appPackage.identifier,
          'api_token': publishConfig.apiToken,
        },
      );

      Map<String, dynamic> data = response.data;
      Map<String, dynamic> cert = data['cert'];

      String releaseId = await _uploadAppBinary(
        file,
        appPackage,
        key: cert['binary']['key'],
        token: cert['binary']['token'],
        uploadUrl: cert['binary']['upload_url'],
        onPublishProgress: onPublishProgress,
      );

      Uri downloadUri = Uri(
        scheme: data['download_domain_https_ready'] ? 'https' : 'http',
        host: data['download_domain'],
        path: '/${data['short']}',
        queryParameters: {'release_id': releaseId},
      );

      return PublishResult(
        url: downloadUri.toString(),
      );
    } on DioException catch (error) {
      String? message;
      if (error.response?.data != null) {
        int? code = error.response?.data['code'];
        message = error.response?.data['errors']['exception'][0];
        message = '$code - $message';
      }
      throw PublishError(message);
    } catch (error) {
      rethrow;
    }
  }
}
