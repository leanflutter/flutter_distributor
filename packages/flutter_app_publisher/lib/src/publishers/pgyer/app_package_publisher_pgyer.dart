import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:dio/dio.dart';

const kEnvPgyerApiKey = 'PGYER_API_KEY';

/// pgyer doc [https://www.pgyer.com/doc/view/api#uploadApp]
class AppPackagePublisherPgyer extends AppPackagePublisher {
  @override
  String get name => 'pgyer';

  // dio 网络请求实例
  final Dio _dio = Dio();
  // 轮询尝试次数
  int tryCount = 0;
  // 最大尝试轮询次数
  final maxTryCount = 10;

  @override
  Future<PublishResult> publish(
    FileSystemEntity fileSystemEntity, {
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    File file = fileSystemEntity as File;
    String? apiKey = (environment ?? Platform.environment)[kEnvPgyerApiKey];
    if ((apiKey ?? '').isEmpty) {
      throw PublishError('Missing `$kEnvPgyerApiKey` environment variable.');
    }

    var tokenInfo = await getCOSToken(apiKey!, file.path);
    String uploadKey = await uploadApp(tokenInfo, file, onPublishProgress);
    if (uploadKey.isEmpty) {
      throw PublishError('UploadApp error');
    }
    // 重试次数设置为 0
    tryCount = 0;
    var buildResult = await getBuildInfo(apiKey, uploadKey);
    String buildKey = buildResult.data!['data']['buildKey'];
    return PublishResult(
      url: 'http://www.pgyer.com/$buildKey',
    );
  }

  /// 获取上传 Token 信息
  /// [apiKey] apiKey
  /// [filePath] 文件路径
  Future<Response> getCOSToken(String apiKey, String filePath) async {
    FormData formData = FormData.fromMap({
      '_api_key': apiKey,
      'buildType': filePath.split('.').last,
    });
    try {
      Response response = await _dio.post(
        'https://www.pgyer.com/apiv2/app/getCOSToken',
        data: formData,
      );
      if (response.data['code'] != 0) {
        throw PublishError('getCOSToken error: ${response.data}');
      }
      return response;
    } catch (e) {
      throw PublishError(e.toString());
    }
  }

  /// 上传应用
  /// [tokenInfo] token信息
  /// [file] 文件
  /// [onPublishProgress] 进度回调
  Future<String> uploadApp(
    Response tokenInfo,
    File file,
    PublishProgressCallback? onPublishProgress,
  ) async {
    var tokenData = tokenInfo.data['data'];
    String endpoint = tokenData['endpoint'];
    String key = tokenData['key'];
    var params = tokenData['params'];
    FormData formData = FormData.fromMap({
      'key': key,
      'signature': params['signature'],
      'x-cos-security-token': params['x-cos-security-token'],
      'x-cos-meta-file-name': file.path.split('/').last,
      'file': await MultipartFile.fromFile(file.path),
    });

    try {
      Response response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: (int sent, int total) {
          if (onPublishProgress != null) {
            onPublishProgress(sent, total);
          }
        },
      );
      if (response.statusCode == 204) {
        // 上传成功，准备轮询结果
        return key;
      }
    } catch (e) {
      throw PublishError(e.toString());
    }
    return '';
  }

  /// 获取应用发布构建信息
  /// [apiKey] apiKey
  /// [uploadKey] uploadKey
  Future<Response> getBuildInfo(String apiKey, String uploadKey) async {
    if (tryCount > maxTryCount) {
      throw PublishError('getBuildInfo error :Too many retries');
    }
    await Future.delayed(const Duration(seconds: 3));
    try {
      Response response = await _dio.get(
        'https://www.pgyer.com/apiv2/app/buildInfo',
        queryParameters: {
          '_api_key': apiKey,
          'buildKey': uploadKey,
        },
      );
      int code = response.data['code'];
      if (code == 1247) {
        tryCount++;
        print('应用发布信息获取中，请稍等 $tryCount');
        return await getBuildInfo(apiKey, uploadKey);
      } else if (code != 0) {
        throw PublishError('getBuildInfo error: ${response.data}');
      }
      return response;
    } catch (e) {
      throw PublishError(e.toString());
    }
  }
}
