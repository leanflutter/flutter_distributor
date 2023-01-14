import 'dart:io';

import 'app_builder.dart';

class AppBuilderIos extends AppBuilder {
  @override
  String get platform => 'ios';

  @override
  String get buildSubcommand => 'ipa';

  @override
  bool get isSupportedOnCurrentPlatform => Platform.isMacOS;

  @override
  Future<BuildResult> build({
    String? target,
    required Map<String, dynamic> buildArguments,
  }) {
    if (!buildArguments.containsKey('export-options-plist') &&
        !buildArguments.containsKey('export-method')) {
      throw BuildError(
        'Missing `export-options-plist` or `export-method` build argument.',
      );
    }
    return super.build(
      target: target,
      buildArguments: buildArguments,
    );
  }

  @override
  Directory get outputDirectory {
    return Directory('build/ios/ipa');
  }
}
