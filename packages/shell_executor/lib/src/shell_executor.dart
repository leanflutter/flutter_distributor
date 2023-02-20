import 'dart:convert';
import 'dart:io';

import './shell_customizer.dart';

Future<ProcessResult> $(
  String executable,
  List<String> arguments, {
  Map<String, String>? environment,
}) {
    final command = ShellCustomizer.customizeCommand(executable, arguments);

    return ShellExecutor.global.exec(
      command.executable,
      command.arguments,
      environment: environment,
    ); 
}

class ShellExecutor {
  static ShellExecutor global = ShellExecutor();

  Future<ProcessResult> exec(
    String executable,
    List<String> arguments, {
    Map<String, String>? environment,
  }) async {
    final Process process = await Process.start(
      executable,
      arguments,
      environment: environment,
    );

    String? stdoutStr;
    String? stderrStr;

    process.stdout.listen((event) {
      String msg = utf8.decoder.convert(event);
      stdoutStr = '${stdoutStr ?? ''}${msg}';
      stdout.write(msg);
    });
    process.stderr.listen((event) {
      String msg = utf8.decoder.convert(event);
      stderrStr = '${stderrStr ?? ''}${msg}';
      stdout.write(msg);
    });
    int exitCode = await process.exitCode;
    return ProcessResult(process.pid, exitCode, stdoutStr, stderrStr);
  }
}
