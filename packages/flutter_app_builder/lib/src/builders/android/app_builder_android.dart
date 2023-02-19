import 'package:flutter_app_builder/src/build_result.dart';

import '../app_builder.dart';
import 'build_android_result.dart';

class AppBuilderAndroid extends AppBuilder {
  @override
  String get platform => 'android';

  @override
  bool get isSupportedOnCurrentPlatform => true;

  @override
  String get buildSubcommand => target == 'aab' ? 'appbundle' : 'apk';

  @override
  BuildResultResolver get resultResolver => BuildAndroidResultResolver(target);

  final String target;

  AppBuilderAndroid(this.target);

  factory AppBuilderAndroid.aab() {
    return AppBuilderAndroid('aab');
  }

  factory AppBuilderAndroid.apk() {
    return AppBuilderAndroid('apk');
  }
}
