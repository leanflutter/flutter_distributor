import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';

class CommandPublish extends Command {
  final FlutterDistributor distributor;

  CommandPublish(this.distributor) {
    argParser.addOption('path', valueHelp: '');
    argParser.addOption('targets', valueHelp: '');
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
    }..removeWhere((key, value) => value == null);

    await distributor.publish(
      File(path),
      targets,
      publishArguments: publishArguments,
    );
  }
}
