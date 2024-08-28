import 'dart:io';

import 'package:flutter_app_publisher/src/api/app_package_publisher.dart';

const kEnvGithubToken = 'GITHUB_TOKEN';
const kEnvGithubRepositoryOwner = 'GITHUB_REPOSITORY_OWNER';
const kEnvGithubRepository = 'GITHUB_REPOSITORY';

class PublishGithubConfig extends PublishConfig {
  PublishGithubConfig({
    required this.token,
    required this.repoOwner,
    required this.repoName,
    this.releaseTitle,
  });

  factory PublishGithubConfig.parse(
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
  ) {
    String? token = (environment ?? Platform.environment)[kEnvGithubToken];
    String? githubRepository =
        (environment ?? Platform.environment)[kEnvGithubRepository];
    String? githubRepositoryOwner =
        (environment ?? Platform.environment)[kEnvGithubRepositoryOwner];
    if ((token ?? '').isEmpty) {
      throw PublishError('Missing `$kEnvGithubToken` environment variable.');
    }
    String? owner = publishArguments?['repo-owner'];
    if ((owner ?? '').isEmpty && githubRepositoryOwner?.isNotEmpty == true) {
      print(
        'Using provided $githubRepositoryOwner from ENV '
        '$kEnvGithubRepositoryOwner as repo-owner',
      );
      owner = githubRepositoryOwner;
    }

    String? name = publishArguments?['repo-name'];
    if ((owner ?? '').isEmpty &&
        githubRepository?.isNotEmpty == true &&
        githubRepository!.contains('/')) {
      print(
        'Extracting repo name from provided $githubRepository from ENV '
        '$kEnvGithubRepository as repo-name',
      );
      var parts = githubRepository.split('/');
      if ((owner ?? '').isEmpty) {
        owner = parts[0];
      } else if (owner != parts[0]) {
        throw PublishError(
          '<repo-name> is mismatch error between $githubRepository from ENV '
          '$kEnvGithubRepository and $githubRepositoryOwner from ENV '
          '$kEnvGithubRepositoryOwner',
        );
      }
      name = parts[1];
    }
    if ((owner ?? '').isEmpty) {
      throw PublishError('<repo-owner> is null');
    }
    if ((name ?? '').isEmpty) {
      throw PublishError('<repo-name> is null');
    }

    PublishGithubConfig publishConfig = PublishGithubConfig(
      token: token!,
      repoOwner: owner!,
      repoName: name!,
      releaseTitle: publishArguments?['release-title'],
    );

    String appVersion =
        publishConfig.pubspec.version.toString().split('+').first;
    String appBuildNumber =
        publishConfig.pubspec.version.toString().split('+').last;

    if ((publishConfig.releaseTitle ?? '').trim().isEmpty) {
      publishConfig.releaseTitle = 'v$appVersion';
    } else {
      publishConfig.releaseTitle = publishConfig.releaseTitle
          ?.replaceAll('{appVersion}', appVersion)
          .replaceAll('{appBuildNumber}', appBuildNumber);
    }

    return publishConfig;
  }

  // Personal access tokens
  final String token;
  // Repository Owner
  String repoOwner;
  // Repository Name
  String repoName;
  // Release title
  String? releaseTitle;
}
