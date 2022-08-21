import 'dart:convert';
import 'dart:io';

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

    String stdoutStr = '';
    String stderrStr = '';

    process.stdout.listen((event) {
      String msg = utf8.decoder.convert(event);
      stdoutStr += msg;
      stdout.write(msg);
    });
    process.stderr.listen((event) {
      String msg = utf8.decoder.convert(event);
      stderrStr += msg;
      stdout.write(msg);
    });
    int exitCode = await process.exitCode;
    return ProcessResult(process.pid, exitCode, stdoutStr, stderrStr);
  }
}
