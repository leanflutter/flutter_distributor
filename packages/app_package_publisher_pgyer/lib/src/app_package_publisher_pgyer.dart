import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:dio/dio.dart';

import 'publish_pgyer_config.dart';

const kEnvPgyerApiKey = 'PGYER_API_KEY';

/// pgyer doc [https://www.pgyer.com/doc/view/api#uploadApp]
class AppPackagePublisherPgyer extends AppPackagePublisher {
  String get name => 'pgyer';

  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://www.pgyer.com'),
  );

  @override
  Future<PublishResult> publish(
    File file, {
    Map<String, String>? environment,
    PublishProgressCallback? onPublishProgress,
  }) async {
    String? apiKey = (environment ?? Platform.environment)[kEnvPgyerApiKey];
    if ((apiKey ?? '').isEmpty) {
      throw PublishError('Missing `$kEnvPgyerApiKey` environment variable.');
    }

    PublishPgyerConfig publishConfig = PublishPgyerConfig(
      apiKey: apiKey!,
    );

    FormData formData = FormData.fromMap({
      '_api_key': publishConfig.apiKey,
      'file': await MultipartFile.fromFile(file.path),
    });

    Response response = await _dio.post(
      '/apiv2/app/upload',
      data: formData,
      onSendProgress: (int sent, int total) {
        if (onPublishProgress != null) {
          onPublishProgress(sent, total);
        }
      },
    );

    int? code = response.data['code'];
    if (code != 0) {
      String message = response.data['message'];
      throw PublishError('$code - $message');
    }

    String buildKey = response.data!['data']['buildKey'];
    return PublishResult(
      url: 'http://www.pgyer.com/$buildKey',
    );
  }
}
