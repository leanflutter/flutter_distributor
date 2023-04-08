import 'dart:convert';
import 'dart:io';

import 'package:flutter_distributor/src/extensions/string.dart';
import 'package:flutter_distributor/src/utils/logger.dart';
import 'package:shell_executor/shell_executor.dart';

class DefaultShellExecutor extends ShellExecutor {
  @override
  Future<ProcessResult> exec(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    final Process process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      runInShell: true,
    );

    logger.info('\$ $executable ${arguments.join(' ')}'.brightBlack());

    String? stdoutStr;
    String? stderrStr;

    process.stdout.listen((event) {
      String msg = utf8.decoder.convert(event);
      stdoutStr = '${stdoutStr ?? ''}$msg';
      stdout.write(msg.brightBlack());
    });
    process.stderr.listen((event) {
      String msg = utf8.decoder.convert(event);
      stderrStr = '${stderrStr ?? ''}$msg';
      stderr.write(msg.brightRed());
    });
    int exitCode = await process.exitCode;
    return ProcessResult(process.pid, exitCode, stdoutStr, stderrStr);
  }
}
