import 'dart:io';

import 'app_builder.dart';

class AppBuilderWeb extends AppBuilder {
  @override
  String get platform => 'web';

  @override
  Directory getOutputDirectory({
    String? flavor,
    String? target,
  }) {
    return Directory('build/web');
  }
}
