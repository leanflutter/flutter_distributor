import 'dart:io';

import 'package:shell_executor/src/shell_executor.dart';

abstract class Command {
  String get executable => throw UnimplementedError();

  Future<void> install();

  Future<ProcessResult> exec(
    List<String> arguments, {
    Map<String, String>? environment,
  }) {
    return $(
      executable,
      arguments,
      environment: environment,
    );
  }
}
