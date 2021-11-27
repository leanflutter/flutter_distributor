import 'dart:io';

import 'app_builder.dart';

class AppBuilderLinux extends AppBuilder {
  @override
  String get platform => 'linux';

  @override
  Directory getOutputDirectory({
    String? flavor,
    String? target,
  }) {
    return Directory('build/linux/x64/release/bundle');
  }
}
