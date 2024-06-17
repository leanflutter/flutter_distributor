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

/// process with pipe
Future<ProcessResult> $$(
  String executable1,
  List<String> arguments1,
  String executable2,
  List<String> arguments2, {
  String? workingDirectory,
  Map<String, String>? environment,
}) {
  return ShellExecutor.global.pipe(
    executable1,
    arguments1,
    executable2,
    arguments2,
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

  Future<ProcessResult> pipe(
    String executable1,
    List<String> arguments1,
    String executable2,
    List<String> arguments2, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    final Process process1 = await Process.start(
      executable1,
      arguments1,
      workingDirectory: workingDirectory,
      environment: environment,
    );
    final Process process2 = await Process.start(
      executable2,
      arguments2,
      workingDirectory: workingDirectory,
      environment: environment,
    );

    if (process1.exitCode != 0) {
      String? stdoutStr = _stdout(process1);
      String? stderrStr = _stderr(process1);
      int exitCode = await process1.exitCode;
      return ProcessResult(process1.pid, exitCode, stdoutStr, stderrStr);
    }

    process1.stdout.pipe(process2.stdin);

    String? stdoutStr = _stdout(process2);
    String? stderrStr = _stderr(process2);
    int exitCode = await process2.exitCode;
    return ProcessResult(process2.pid, exitCode, stdoutStr, stderrStr);
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

  String _stderr(Process process) {
    String? stderrStr;
    process.stderr.listen((event) {
      String msg = utf8.decoder.convert(event);
      stderrStr = '${stderrStr ?? ''}$msg';
      stderr.write(msg);
    });
    return stderrStr ?? '';
  }

  String _stdout(Process process) {
    String? stdoutStr;
    process.stdout.listen((event) {
      String msg = utf8.decoder.convert(event);
      stdoutStr = '${stdoutStr ?? ''}$msg';
      stdout.write(msg);
    });
    return stdoutStr ?? '';
  }
}
