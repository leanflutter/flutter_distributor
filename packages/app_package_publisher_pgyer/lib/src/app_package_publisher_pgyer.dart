import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:dio/dio.dart';

import 'publish_pgyer_config.dart';

/// pgyer doc [https://www.pgyer.com/doc/view/api#uploadApp]
class AppPackagePublisherPgyer extends AppPackagePublisher {
  String get name => 'pgyer';

  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://www.pgyer.com'),
  );

  @override
  Future<PublishResult> publish(
    File file, {
    ProgressUpdateCallback? onProgressUpdate,
  }) async {
    String? apiToken = Platform.environment['PGYER_API_TOKEN'];

    if (apiToken?.isEmpty ?? true) {
      throw PublishError(
          'Please set `PGYER_API_TOKEN` to your environment, e.g. '
          'export PGYER_API_TOKEN="xxx"');
    }

    PublishPgyerConfig publishConfig = PublishPgyerConfig(
      apiToken: apiToken!,
    );

    FormData formData = FormData.fromMap({
      '_api_key': publishConfig.apiToken,
      'file': await MultipartFile.fromFile(file.path),
    });

    Response response = await _dio.post(
      '/apiv2/app/upload',
      data: formData,
      onSendProgress: (int sent, int total) {
        if (onProgressUpdate != null) {
          onProgressUpdate(sent / total);
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
