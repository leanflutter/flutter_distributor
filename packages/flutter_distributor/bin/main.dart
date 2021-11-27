import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_distributor/flutter_distributor.dart';
import 'package:yaml/yaml.dart';

Future<void> _release(ArgResults options) async {
  final String platform = options['platform'];
  // final List<String> targets = '${options['targets']}'.split(',');

  final yamlString = File('pubspec.yaml').readAsStringSync();
  final yamlDoc = loadYaml(yamlString);

  String pubspecName = yamlDoc['name'];
  String pubspecVersion = yamlDoc['version'];

  FlutterDistributor distributor = FlutterDistributor();
  await distributor.release(
    appName: pubspecName,
    appVersion: pubspecVersion,
    targetPlatform: platform,
    targets: ['dmg', 'zip'],
  );
}

Future<void> main(List<String> args) async {
  var parser = ArgParser();
  parser.addFlag(
    'help',
    abbr: 'h',
    negatable: false,
  );
  parser.addOption(
    'platform',
    valueHelp: 'name',
  );

  final options = parser.parse(args);
  if (options['help'] == true) {
    print('Usage: flutter_distributor release --platform=linux\n');
    print(parser.usage);
    return;
  }

  await _release(options);
}
