import 'dart:convert';
import 'dart:io';

import 'package:ansi_escapes/ansi_escapes.dart';
import 'package:shell_executor/shell_executor.dart';

import '../extensions/extensions.dart';
import 'logger.dart';

class DefaultShellExecutor extends ShellExecutor {
  Future<ProcessResult> exec(
    String executable,
    List<String> arguments, {
    Map<String, String>? environment,
  }) async {
    final Process process = await Process.start(
      executable,
      arguments,
      environment: environment,
      runInShell: true,
    );

    logger.info('\$ $executable ${arguments.join(' ')}'.brightBlack());

    String? stdoutStr;
    String? stderrStr;

    process.stdout.listen((event) {
      String msg = utf8.decoder.convert(event);
      stdoutStr = '${stdoutStr ?? ''}${msg}';
      stdout.write(msg.brightBlack());
    });
    process.stderr.listen((event) {
      String msg = utf8.decoder.convert(event);
      stderrStr = '${stderrStr ?? ''}${msg}';
      stdout.write(msg.brightRed());
    });
    int exitCode = await process.exitCode;
    return ProcessResult(process.pid, exitCode, stdoutStr, stderrStr);
  }
}
