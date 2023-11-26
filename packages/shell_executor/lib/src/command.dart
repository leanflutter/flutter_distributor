import 'dart:io';

import 'package:shell_executor/src/shell_executor.dart';

abstract class Command {
  String get executable => throw UnimplementedError();

  Future<void> install();

  Future<ProcessResult> exec(
    List<String> arguments, {
    Map<String, String>? environment,
  }) {
    return ShellExecutor.global.exec(
      executable,
      arguments,
      environment: environment,
    );
  }

  ProcessResult execSync(
    List<String> arguments, {
    Map<String, String>? environment,
    bool runInShell = false,
  }) {
    return ShellExecutor.global.execSync(
      executable,
      arguments,
      environment: environment,
      runInShell: runInShell,
    );
  }
}
