import 'dart:convert';
import 'dart:io';

import 'package:colorize/colorize.dart';
import 'package:shell_executor/shell_executor.dart';

import 'logger.dart';

class ColorizeShellExecutor extends ShellExecutor {
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

    logger.info('$executable ${arguments.join(' ')}');

    String stdoutStr = '';
    String stderrStr = '';

    process.stdout.listen((event) {
      String msg = utf8.decoder.convert(event);
      stdoutStr += msg;
      stdout.write(Colorize(msg).darkGray());
    });
    process.stderr.listen((event) {
      String msg = utf8.decoder.convert(event);
      stderrStr += msg;
      stdout.write(Colorize(msg).lightRed());
    });
    int exitCode = await process.exitCode;
    return ProcessResult(process.pid, exitCode, stdoutStr, stderrStr);
  }
}
