import 'dart:io';

import 'package:flutter_app_builder/src/build_result.dart';

import '../app_builder.dart';
import 'build_macos_result.dart';

class AppBuilderMacOs extends AppBuilder {
  @override
  String get platform => 'macos';

  @override
  bool get isSupportedOnCurrentPlatform => Platform.isMacOS;

  @override
  BuildResultResolver get resultResolver => BuildMacOsResultResolver();
}
