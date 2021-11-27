import 'dart:io';

import 'app_builder.dart';

class AppBuilderMacOs extends AppBuilder {
  @override
  String get platform => 'macos';

  @override
  Directory getOutputDirectory({
    String? flavor,
    String? target,
  }) {
    return Directory('build/macos/Build/Products/Release');
  }
}
