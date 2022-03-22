import 'dart:io';

import 'app_builder.dart';

class AppBuilderAndroid extends AppBuilder {
  final String target;

  AppBuilderAndroid(this.target);

  @override
  String get platform => 'android';

  @override
  String get buildSubcommand => target == 'aab' ? 'appbundle' : 'apk';

  @override
  bool get isSupportedOnCurrentPlatform => true;

  @override
  Directory get outputDirectory {
    if (target == 'aab') {
      return Directory('build/app/outputs/bundle');
    } else {
      return Directory('build/app/outputs/flutter-apk');
    }
  }

  factory AppBuilderAndroid.aab() {
    return AppBuilderAndroid('aab');
  }

  factory AppBuilderAndroid.apk() {
    return AppBuilderAndroid('apk');
  }
}
