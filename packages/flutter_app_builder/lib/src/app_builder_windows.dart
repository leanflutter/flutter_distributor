import 'dart:io';

import 'app_builder.dart';

class AppBuilderWindows extends AppBuilder {
  @override
  String get platform => 'windows';

  @override
  Directory getOutputDirectory({
    String? flavor,
    String? target,
  }) {
    return Directory('build/windows/runner/Release');
  }
}
