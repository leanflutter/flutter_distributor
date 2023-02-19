import 'dart:convert';

import 'package:flutter_app_builder/src/build_config.dart';
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
    String platform,
    String target, {
    required Map<String, dynamic> buildArguments,
  }) async {
    AppBuilder builder = _builders.firstWhere(
      (e) {
        if (e.platform == platform && e is AppBuilderAndroid) {
          return e.target == target;
        }
        return e.platform == platform;
      },
    );

    if (!builder.isSupportedOnCurrentPlatform) {
      throw UnsupportedError(
        '${builder.runtimeType} is not supported on the current platform',
      );
    }

    BuildConfig config = BuildConfig(
      arguments: buildArguments,
    );
    JsonEncoder _encoder = JsonEncoder.withIndent('  ');
    BuildResult result = await builder.build(config);
    print(_encoder.convert(result.toJson()));
    return result;
  }
}
