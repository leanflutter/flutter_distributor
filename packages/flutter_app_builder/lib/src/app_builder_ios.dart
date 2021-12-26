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
    Map<String, dynamic> buildArguments = const {},
    ProcessStdOutCallback? onBuildProcessStdOut,
    ProcessStdErrCallback? onBuildProcessStdErr,
  }) {
    if (!buildArguments.containsKey('export-options-plist')) {
      throw BuildError('Missing `export-options-plist` build argument.');
    }
    return super.build(
      target: target,
      buildArguments: buildArguments,
      onBuildProcessStdOut: onBuildProcessStdOut,
      onBuildProcessStdErr: onBuildProcessStdErr,
    );
  }

  @override
  Directory get outputDirectory {
    return Directory('build/ios/ipa');
  }
}
