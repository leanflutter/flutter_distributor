import 'dart:io';

import 'package:flutter_app_builder/src/build_error.dart';
import 'package:flutter_app_builder/src/builders/app_builder.dart';
import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/build_result.dart';
import 'package:flutter_app_builder/src/builders/ios/build_ios_result.dart';

class AppBuilderIos extends AppBuilder {
  @override
  String get platform => 'ios';

  @override
  bool get isSupportedOnCurrentPlatform => Platform.isMacOS;

  @override
  BuildResultResolver get resultResolver => BuildIosResultResolver();

  @override
  String get buildSubcommand => 'ipa';

  @override
  Future<BuildResult> build(BuildConfig config) {
    if (!config.arguments.containsKey('export-options-plist') &&
        !config.arguments.containsKey('export-method')) {
      throw BuildError(
        'Missing `export-options-plist` or `export-method` build argument.',
      );
    }
    return super.build(config);
  }
}
