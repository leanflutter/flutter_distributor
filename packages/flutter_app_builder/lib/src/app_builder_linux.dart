import 'dart:io';

import 'app_builder.dart';

class AppBuilderLinux extends AppBuilder {
  @override
  String get platform => 'linux';

  @override
  bool get isSupportedOnCurrentPlatform => Platform.isLinux;

  @override
  Directory get outputDirectory {
    return Directory('build/linux/x64/release/bundle');
  }
}
