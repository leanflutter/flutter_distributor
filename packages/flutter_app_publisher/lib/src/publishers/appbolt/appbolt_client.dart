import 'package:dio/dio.dart';

class AppboltClient {
  AppboltClient({required this.apiToken});

  final String apiToken;

  final Dio _dio = Dio();

  Future<Map<String, dynamic>> createRelease(
    String appId, {
    required String releaseVersion,
  }) async {
    final response = await _dio.post(
      '/apps/$appId/releases',
      data: {
        'releaseVersion': releaseVersion,
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.data['message']);
    }
    return response.data;
  }
}
