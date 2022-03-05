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
    bool cleanBeforeBuild = false,
    required Map<String, dynamic> buildArguments,
    required void Function(List<int> data) onProcessStdOut,
    required void Function(List<int> data) onProcessStdErr,
  }) {
    if (!buildArguments.containsKey('export-options-plist')) {
      throw BuildError('Missing `export-options-plist` build argument.');
    }
    return super.build(
      target: target,
      cleanBeforeBuild: cleanBeforeBuild,
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
