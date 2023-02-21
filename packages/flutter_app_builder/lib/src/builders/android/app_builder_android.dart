import 'package:flutter_app_builder/src/build_result.dart';
import 'package:flutter_app_builder/src/builders/android/build_android_result.dart';
import 'package:flutter_app_builder/src/builders/app_builder.dart';

class AppBuilderAndroid extends AppBuilder {
  AppBuilderAndroid(this.target);

  factory AppBuilderAndroid.apk() {
    return AppBuilderAndroid('apk');
  }

  factory AppBuilderAndroid.aab() {
    return AppBuilderAndroid('aab');
  }

  @override
  String get platform => 'android';

  @override
  bool get isSupportedOnCurrentPlatform => true;

  @override
  BuildResultResolver get resultResolver => BuildAndroidResultResolver(target);

  @override
  String get buildSubcommand => target == 'aab' ? 'appbundle' : 'apk';

  final String target;

  bool match(String platform, [String? target]) {
    return this.platform == platform && this.target == target;
  }
}
