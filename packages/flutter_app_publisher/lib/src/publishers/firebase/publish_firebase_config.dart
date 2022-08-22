import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

const kEnvFirebaseToken = 'FIREBASE_TOKEN';

class PublishFirebaseConfig extends PublishConfig {
  final String app;
  final String? token;
  final String? releaseNotes;
  final String? releaseNotesFile;
  final String? testers;
  final String? testersFile;
  final String? groups;
  final String? groupsFile;

  PublishFirebaseConfig({
    required this.app,
    this.token,
    this.releaseNotes,
    this.releaseNotesFile,
    this.testers,
    this.testersFile,
    this.groups,
    this.groupsFile,
  });

  factory PublishFirebaseConfig.parse(Map<String, String>? environment,
      Map<String, dynamic>? publishArguments) {
    // Get token
    String? token = (environment ?? Platform.environment)[kEnvFirebaseToken];
    if ((token ?? '').isEmpty) {
      throw PublishError(
          'Missing `$kEnvFirebaseToken` environment variable. See:https://firebase.google.com/docs/cli?authuser=0#cli-ci-systems');
    }
    // Get app
    String? app = publishArguments?['app'];
    if ((app ?? '').isEmpty) {
      throw PublishError(
          'Missing app args. See:https://console.firebase.google.com/project/_/settings/general/?authuser=0');
    }
    return PublishFirebaseConfig(
      app: app!,
      token: token!,
      releaseNotes: publishArguments?['release-notes'],
      releaseNotesFile: publishArguments?['release-notes-file'],
      testers: publishArguments?['testers'],
      testersFile: publishArguments?['testers-file'],
      groups: publishArguments?['groups'],
      groupsFile: publishArguments?['groups-file'],
    );
  }

  List<String> toFirebaseCliDistributeArgs() {
    Map<String, String?> cmdData = {
      '--app': app,
      '--token': token,
      '--release-notes': releaseNotes,
      '--release-notes-file': releaseNotesFile,
      '--testers': testers,
      '--testers-file': testersFile,
      '--groups': groups,
      '--groups-file': groupsFile,
    };
    // clean null value cmd
    cmdData.removeWhere((key, value) => value?.isEmpty ?? true);
    // format cmd
    List<String> cmdList = [];
    cmdData.forEach((key, value) {
      cmdList.addAll([key, value!]);
    });
    return cmdList;
  }
}
