import 'package:shell_executor/src/command.dart';

class CommandError extends Error {
  CommandError(this.command, [this.message]);

  final Command command;
  final String? message;

  @override
  String toString() {
    return (message != null) ? 'CommandError: $message' : 'CommandError';
  }
}
