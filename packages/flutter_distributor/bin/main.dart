import 'package:args/args.dart';
import 'package:args/command_runner.dart';

// import 'command_doctor.dart';
import 'command_package.dart';
import 'command_publish.dart';
// import 'command_release.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner('flutter_distributor', '');

  // runner.addCommand(CommandDoctor());
  runner.addCommand(CommandPackage());
  runner.addCommand(CommandPublish());
  // runner.addCommand(CommandRelease());

  ArgResults argResults = runner.parse(args);
  await runner.runCommand(argResults);
}
