import 'dart:io';

import 'app_builder.dart';

class AppBuilderWindows extends AppBuilder {
  @override
  String get platform => 'windows';

  @override
  bool get isSupportedOnCurrentPlatform => Platform.isWindows;

  @override
  Directory get outputDirectory {
    return Directory('build/windows/runner/Release');
  }
}
