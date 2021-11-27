import 'dart:io';

import 'app_builder.dart';

class AppBuilderAndroid extends AppBuilder {
  @override
  String get platform => 'android';

  @override
  Directory getOutputDirectory({
    String? flavor,
    String? target,
  }) {
    if (target == 'aab') {
      return Directory('build/app/outputs/bundle/release');
    } else {
      return Directory('build/app/outputs/apk/release');
    }
  }
}
