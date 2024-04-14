import 'dart:io';

import 'package:shell_executor/src/shell_executor.dart';

abstract class Command {
  String get executable => throw UnimplementedError();

  Future<void> install();

  Future<ProcessResult> exec(
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) {
    return ShellExecutor.global.exec(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
    );
  }

  ProcessResult execSync(
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = false,
  }) {
    return ShellExecutor.global.execSync(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      runInShell: runInShell,
    );
  }
}
