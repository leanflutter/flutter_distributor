import 'package:args/command_runner.dart';

class CommandDoctor extends Command {
  @override
  String get name => 'doctor';

  @override
  String get description => 'Show information about the installed tooling.';
}
