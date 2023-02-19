import 'dart:io';

import 'package:flutter_app_builder/src/build_result.dart';

import '../app_builder.dart';
import 'build_windows_result.dart';

class AppBuilderWindows extends AppBuilder {
  @override
  String get platform => 'windows';

  @override
  bool get isSupportedOnCurrentPlatform => Platform.isWindows;

  @override
  BuildResultResolver get resultResolver => BuildWindowsResultResolver();
}
