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
  Directory get outputDirectory {
    return Directory('build/ios/ipa');
  }
}
