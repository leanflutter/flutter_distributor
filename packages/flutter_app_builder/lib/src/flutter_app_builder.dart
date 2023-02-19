import 'package:flutter_app_builder/src/build_result.dart';
import 'package:flutter_app_builder/src/builders/builders.dart';
import 'package:shell_executor/shell_executor.dart';

class FlutterAppBuilder {
  final List<AppBuilder> _builders = [
    AppBuilderAndroid.aab(),
    AppBuilderAndroid.apk(),
    AppBuilderIos(),
    AppBuilderLinux(),
    AppBuilderMacOs(),
    AppBuilderWeb(),
    AppBuilderWindows(),
  ];

  Future<void> clean() async {
    await $('flutter', ['clean']);
  }

  Future<BuildResult> build(
    String platform, {
    String? target,
    required Map<String, dynamic> arguments,
  }) {
    final builder = _builders.firstWhere((e) => e.match(platform, target));
    if (!builder.isSupportedOnCurrentPlatform) {
      throw UnsupportedError(
        '${builder.runtimeType} is not supported on the current platform',
      );
    }
    return builder.build(arguments: arguments);
  }
}
