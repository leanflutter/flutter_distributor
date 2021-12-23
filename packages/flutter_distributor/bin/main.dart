import 'package:args/args.dart';
import 'package:flutter_distributor/flutter_distributor.dart';

Future<void> _release(ArgResults options) async {
  final String platform = options['platform'];
  final List<String> targets = '${options['targets']}'.split(',');

  FlutterDistributor distributor = FlutterDistributor();
  await distributor.release(
    targetPlatform: platform,
    targets: targets,
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
  parser.addOption(
    'targets',
    valueHelp: '',
  );

  final options = parser.parse(args);
  if (options['help'] == true) {
    print('Usage: flutter_distributor --platform=linux\n');
    print(parser.usage);
    return;
  }

  await _release(options);
}
