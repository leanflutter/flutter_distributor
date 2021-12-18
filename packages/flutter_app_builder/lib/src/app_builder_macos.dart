import 'dart:io';

import 'app_builder.dart';

class AppBuilderMacOs extends AppBuilder {
  @override
  String get platform => 'macos';

  @override
  bool get isSupportedOnCurrentPlatform => Platform.isMacOS;

  @override
  Directory get outputDirectory {
    return Directory('build/macos/Build/Products/Release');
  }
}
