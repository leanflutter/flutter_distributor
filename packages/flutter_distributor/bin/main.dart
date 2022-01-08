import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';

// import 'command_doctor.dart';
import 'command_package.dart';
import 'command_publish.dart';
import 'command_release.dart';
import 'command_upgrade.dart';

Future<void> main(List<String> args) async {
  FlutterDistributor distributor = FlutterDistributor();
  await distributor.checkVersion();

  final runner = CommandRunner('flutter_distributor', '');

  // runner.addCommand(CommandDoctor());
  runner.addCommand(CommandPackage(distributor));
  runner.addCommand(CommandPublish(distributor));
  runner.addCommand(CommandRelease(distributor));
  runner.addCommand(CommandUpgrade(distributor));

  ArgResults argResults = runner.parse(args);
  await runner.runCommand(argResults);
}
