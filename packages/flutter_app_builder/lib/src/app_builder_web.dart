import 'dart:io';

import 'app_builder.dart';

class AppBuilderWeb extends AppBuilder {
  @override
  String get platform => 'web';

  @override
  bool get isSupportedOnCurrentPlatform => true;

  @override
  Directory get outputDirectory {
    return Directory('build/web');
  }
}
