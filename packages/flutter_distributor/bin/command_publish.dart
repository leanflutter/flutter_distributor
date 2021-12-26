import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';

class CommandPublish extends Command {
  final FlutterDistributor distributor;

  CommandPublish(this.distributor) {
    argParser.addOption('path', valueHelp: '');
    argParser.addOption('targets', valueHelp: '');
  }

  @override
  String get name => 'publish';

  @override
  String get description => 'Publish the current Flutter application';

  @override
  Future run() async {
    String path = argResults?['path'];
    List<String> targets = '${argResults?['targets']}'.split(',');

    await distributor.publish(File(path), targets);
  }
}
