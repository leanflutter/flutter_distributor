import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

const kEnvGithubToken = 'GITHUB_TOKEN';

class PublishGithubConfig extends PublishConfig {
  // Personal access tokens
  final String token;
  // Repository Owner
  String repoOwner;
  // Repository Name
  String repoName;

  factory PublishGithubConfig.parse(
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
  ) {
    String? token = (environment ?? Platform.environment)[kEnvGithubToken];
    if ((token ?? '').isEmpty) {
      throw PublishError('Missing `$kEnvGithubToken` environment variable.');
    }
    print("publishArguments:${publishArguments.toString()}");
    String? owner = publishArguments?['repo-owner'];
    if ((owner ?? '').isEmpty) {
      throw PublishError('<repo-owner> is null');
    }

    String? name = publishArguments?['repo-name'];
    if ((name ?? '').isEmpty) {
      throw PublishError('<repo-name> is null');
    }

    return PublishGithubConfig(
      token: token!,
      repoOwner: owner!,
      repoName: name!,
    );
  }

  PublishGithubConfig({
    required this.token,
    required this.repoOwner,
    required this.repoName,
  });
}
