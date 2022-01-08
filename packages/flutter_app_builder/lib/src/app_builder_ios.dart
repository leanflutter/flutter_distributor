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
    bool cleanOnceBeforeBuild = false,
    required Map<String, dynamic> buildArguments,
    required ProcessStdOutCallback onProcessStdOut,
    required ProcessStdErrCallback onProcessStdErr,
  }) {
    if (!buildArguments.containsKey('export-options-plist')) {
      throw BuildError('Missing `export-options-plist` build argument.');
    }
    return super.build(
      target: target,
      cleanOnceBeforeBuild: cleanOnceBeforeBuild,
      buildArguments: buildArguments,
      onProcessStdOut: onProcessStdOut,
      onProcessStdErr: onProcessStdErr,
    );
  }

  @override
  Directory get outputDirectory {
    return Directory('build/ios/ipa');
  }
}
