import 'package:flutter_app_builder/src/build_result.dart';
import 'package:flutter_app_builder/src/builders/app_builder.dart';
import 'package:flutter_app_builder/src/builders/web/build_web_result.dart';

class AppBuilderWeb extends AppBuilder {
  @override
  String get platform => 'web';

  @override
  bool get isSupportedOnCurrentPlatform => true;

  @override
  BuildResultResolver get resultResolver => BuildWebResultResolver();
}
