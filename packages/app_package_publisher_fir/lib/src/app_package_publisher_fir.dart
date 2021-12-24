import 'dart:convert';
import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:dio/dio.dart';
import 'package:dio/src/dio_error.dart';
import 'package:parse_app_package/parse_app_package.dart';

import 'publish_fir_config.dart';

class AppPackagePublisherFir extends AppPackagePublisher {
  @override
  String get name => 'fir';

  @override
  List<String> get supportedPlatforms => ['android', 'ios'];

  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'http://api.bq04.com'),
  );

  Future<void> _uploadAppBinary(
    File file,
    AppPackage appPackage, {
    required String key,
    required String token,
    required String uploadUrl,
    ProgressUpdateCallback? onProgressUpdate,
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
        if (onProgressUpdate != null) {
          onProgressUpdate(sent / total);
        }
      },
    );
    print(json.encode(response.data));
  }

  @override
  Future<PublishResult> publish(
    File file, {
    ProgressUpdateCallback? onProgressUpdate,
  }) async {
    String? apiToken = Platform.environment['FIR_API_TOKEN'];

    if (apiToken?.isEmpty ?? true) {
      throw PublishError('Please set `FIR_API_TOKEN` to your environment, e.g. '
          'export FIR_API_TOKEN="xxx"');
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

      await _uploadAppBinary(
        file,
        appPackage,
        key: cert['binary']['key'],
        token: cert['binary']['token'],
        uploadUrl: cert['binary']['upload_url'],
        onProgressUpdate: onProgressUpdate,
      );

      Uri downloadUri = Uri(
        scheme: data['download_domain_https_ready'] ? 'https' : 'http',
        host: data['download_domain'],
        path: '/${data['short']}',
      );

      return PublishResult(
        url: downloadUri.toString(),
      );
    } on DioError catch (error) {
      String? message;
      if (error.response?.data != null) {
        int code = error.response?.data['code'];
        message = error.response?.data['errors']['exception'][0];
        message = '$code - $message';
      }
      throw PublishError(message);
    } catch (error) {
      throw error;
    }
  }
}
