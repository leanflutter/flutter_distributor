import 'dart:convert';
import 'dart:io';

Future<ProcessResult> $(
  String executable,
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

class ShellExecutor {
  static ShellExecutor global = ShellExecutor();

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
    );

    String? stdoutStr;
    String? stderrStr;

    process.stdout.listen((event) {
      String msg = utf8.decoder.convert(event);
      stdoutStr = '${stdoutStr ?? ''}$msg';
      stdout.write(msg);
    });
    process.stderr.listen((event) {
      String msg = utf8.decoder.convert(event);
      stderrStr = '${stderrStr ?? ''}$msg';
      stderr.write(msg);
    });
    int exitCode = await process.exitCode;
    return ProcessResult(process.pid, exitCode, stdoutStr, stderrStr);
  }

  ProcessResult execSync(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = false,
  }) {
    final ProcessResult processResult = Process.runSync(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      runInShell: runInShell,
    );
    return processResult;
  }
}
