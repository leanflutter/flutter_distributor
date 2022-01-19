import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

const kEnvGithubToken = 'GITHUB_TOKEN';

class PublishGithubConfig extends PublishConfig {
  final String token;
  String? rep;
  String? releaseId;

  factory PublishGithubConfig.parse(
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
  ) {
    String? token = (environment ?? Platform.environment)[kEnvGithubToken];
    if ((token ?? '').isEmpty) {
      throw PublishError('Missing `$kEnvGithubToken` environment variable.');
    }
    return PublishGithubConfig(
      token: token!,
      rep: publishArguments?['rep'],
      releaseId: publishArguments?['release_id'] ?? '',
    );
  }

  PublishGithubConfig({
    required this.token,
    this.rep,
    this.releaseId,
  });
}
