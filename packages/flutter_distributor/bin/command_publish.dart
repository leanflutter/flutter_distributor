import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';

class CommandPublish extends Command {
  final FlutterDistributor distributor;

  CommandPublish(this.distributor) {
    argParser.addOption('path', valueHelp: '');
    argParser.addOption('targets', valueHelp: '');
    // Firebase
    argParser.addSeparator('firebase');
    argParser.addOption('firebase-release-notes', valueHelp: '');
    argParser.addOption('firebase-release-notes-file', valueHelp: '');
    argParser.addOption('firebase-testers', valueHelp: '');
    argParser.addOption('firebase-testers-file', valueHelp: '');
    argParser.addOption('firebase-groups', valueHelp: '');
    argParser.addOption('firebase-groups-file', valueHelp: '');
    // Qiniu
    argParser.addSeparator('qiniu');
    argParser.addOption('qiniu-bucket', valueHelp: '');
    argParser.addOption('qiniu-bucket-domain', valueHelp: '');
    argParser.addOption('qiniu-savekey-prefix', valueHelp: '');
  }

  @override
  String get name => 'publish';

  @override
  String get description => 'Publish the current Flutter application';

  @override
  Future run() async {
    String path = argResults?['path'];
    List<String> targets = '${argResults?['targets']}'.split(',');
    Map<String, String?> publishArguments = {
      'qiniu-bucket': argResults?['qiniu-bucket'],
      'qiniu-bucket-domain': argResults?['qiniu-bucket-domain'],
      'qiniu-savekey-prefix': argResults?['qiniu-savekey-prefix'],
      'firebase-release-notes': argResults?['firebase-release-notes'],
      'firebase-release-notes-file': argResults?['firebase-release-notes-file'],
      'firebase-testers': argResults?['firebase-testers'],
      'firebase-testers-file': argResults?['firebase-testers-file'],
      'firebase-groups': argResults?['firebase-groups'],
      'firebase-groups-file': argResults?['firebase-groups-file'],
    }..removeWhere((key, value) => value == null);

    await distributor.publish(
      File(path),
      targets,
      publishArguments: publishArguments,
    );
  }
}
