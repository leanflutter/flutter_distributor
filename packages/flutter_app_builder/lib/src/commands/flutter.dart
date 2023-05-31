import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shell_executor/shell_executor.dart';

class _Flutter extends Command {
  @override
  String get executable {
    String flutterRoot = environment?['FLUTTER_ROOT'] ?? '';
    if (flutterRoot.isNotEmpty) {
      flutterRoot = pathExpansion(flutterRoot, environment ?? {});
      return p.join(flutterRoot, 'bin', 'flutter');
    }
    return 'flutter';
  }

  Map<String, String>? environment;

  withEnv(Map<String, String>? environment) {
    this.environment = environment;
    return this;
  }

  Future<void> clean() {
    return exec(
      ['clean'],
      environment: environment,
    );
  }

  Future<ProcessResult> build(List<String> arguments) {
    return exec(
      ['build', ...arguments],
      environment: environment,
    );
  }

  @override
  Future<void> install() {
    throw UnimplementedError();
  }
}

final flutter = _Flutter();
