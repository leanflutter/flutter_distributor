import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';
import 'package:flutter_distributor/src/extensions/extensions.dart';

/// Publish an application to a third party provider
///
/// This command wrapper defines, parses and transforms all passed arguments,
/// so that they may be passed to `flutter_distributor`. The distributor will
/// then publish an application bundle using `flutter_app_publisher`.
class CommandPublish extends Command {
  CommandPublish(this.distributor) {
    argParser.addOption(
      'path',
      valueHelp: '',
      help: 'The path to the application bundle to publish.',
    );

    argParser.addOption(
      'targets',
      aliases: ['target'],
      valueHelp: [
        'appcenter',
        'appstore',
        'fir',
        'firebase',
        'github',
        'playstore',
        'pgyer',
        'qiniu',
        'vercel',
      ].join(','),
      help: 'The target provider(s) to publish to.',
    );

    // AppCenter
    argParser.addSeparator('appcenter');

    argParser.addOption(
      'appcenter-owner-name',
      valueHelp: '',
      help: 'The owner name for appcenter.',
    );

    argParser.addOption(
      'appcenter-app-name',
      valueHelp: '',
      help: 'The app name for appcenter.',
    );

    argParser.addOption(
      'appcenter-distribution-group',
      valueHelp: '',
      help: 'The distribution group for appcenter.',
    );

    // Firebase
    argParser.addSeparator('firebase');

    argParser.addOption(
      'firebase-app',
      valueHelp: '',
      help: [
        'The unique ID of the application on Firebase.',
        'This is NOT your bundle identifier',
      ].join('\n'),
    );

    argParser.addOption(
      'firebase-release-notes',
      valueHelp: '',
      help: 'The release notes for the published application.',
    );

    argParser.addOption(
      'firebase-release-notes-file',
      valueHelp: '',
      help: [
        'The path of a file containing the release notes',
        'This is a more extensive alternative to firebase-release-notes',
      ].join('\n'),
    );

    argParser.addOption(
      'firebase-testers',
      valueHelp: '',
      help:
          'The testers that will be notified about the published application.',
    );

    argParser.addOption(
      'firebase-testers-file',
      valueHelp: '',
      help: [
        'The path of a file containing testers that will be notified',
        'This is a more extensive alternative to firebase-testers',
      ].join('\n'),
    );

    argParser.addOption(
      'firebase-groups',
      valueHelp: '',
      help: 'The groups that will be notified about the published application.',
    );

    argParser.addOption(
      'firebase-groups-file',
      valueHelp: '',
      help: [
        'The path of a file containing groups that will be notified',
        'This is a more extensive alternative to firebase-groups',
      ].join('\n'),
    );

    // Github
    argParser.addSeparator('github');

    argParser.addOption(
      'github-repo-owner',
      valueHelp: '',
      help: 'The name of the target GitHub repository wner (namespace)',
    );

    argParser.addOption(
      'github-repo-name',
      valueHelp: '',
      help: 'The name of the target GitHub repository',
    );

    argParser.addOption(
      'github-release-title',
      valueHelp: '',
      help: 'The title of the new release on GitHub',
    );

    // PlayStore
    argParser.addSeparator('playstore');
    argParser.addOption('playstore-package-name', valueHelp: '');

    // Qiniu
    argParser.addSeparator('qiniu');
    argParser.addOption('qiniu-bucket', valueHelp: '');
    argParser.addOption('qiniu-bucket-domain', valueHelp: '');
    argParser.addOption('qiniu-savekey-prefix', valueHelp: '');

    // Vercel
    argParser.addSeparator('vercel');
    argParser.addOption('vercel-org-id', valueHelp: '');
    argParser.addOption('vercel-project-id', valueHelp: '');
  }

  final FlutterDistributor distributor;

  @override
  String get name => 'publish';

  @override
  String get description => 'Publish the current Flutter application';

  @override
  Future run() async {
    String? path = argResults?['path'];
    List<String> targets = '${argResults?['targets'] ?? ''}'
        .split(',')
        .where((t) => t.isNotEmpty)
        .toList();

    // At least `path` and one `targets` is required for flutter build
    if (path == null) {
      print('\nThe \'path\' options is mandatory!'.red(bold: true));
      exit(1);
    }

    print(targets);
    if (targets.isEmpty) {
      print('\nAt least one \'target\' must be specified!'.red(bold: true));
      exit(1);
    }

    // Required parameters for firebase
    if (targets.contains('firebase')) {
      if (argResults?['firebase-app'] == null) {
        print('\nFirebase app identifier is required for target \'firebase\'');
        exit(1);
      }
    }

    Map<String, String?> publishArguments = {
      'appcenter-owner-name': argResults?['appcenter-owner-name'],
      'appcenter-app-name': argResults?['appcenter-app-name'],
      'appcenter-distribution-group':
          argResults?['appcenter-distribution-group'],
      'firebase-app': argResults?['firebase-app'],
      'firebase-release-notes': argResults?['firebase-release-notes'],
      'firebase-release-notes-file': argResults?['firebase-release-notes-file'],
      'firebase-testers': argResults?['firebase-testers'],
      'firebase-testers-file': argResults?['firebase-testers-file'],
      'firebase-groups': argResults?['firebase-groups'],
      'firebase-groups-file': argResults?['firebase-groups-file'],
      'github-repo-owner': argResults?['github-repo-owner'],
      'github-repo-name': argResults?['github-repo-name'],
      'github-release-title': argResults?['github-release-title'],
      'playstore-package-name': argResults?['playstore-package-name'],
      'qiniu-bucket': argResults?['qiniu-bucket'],
      'qiniu-bucket-domain': argResults?['qiniu-bucket-domain'],
      'qiniu-savekey-prefix': argResults?['qiniu-savekey-prefix'],
      'vercel-org-id': argResults?['vercel-org-id'],
      'vercel-project-id': argResults?['vercel-project-id'],
    }..removeWhere((key, value) => value == null);

    final fileSystemEntity =
        await FileSystemEntity.type(path) == FileSystemEntityType.directory
            ? Directory(path)
            : File(path);

    return distributor.publish(
      fileSystemEntity,
      targets,
      publishArguments: publishArguments,
    );
  }
}
