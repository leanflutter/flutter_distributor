import '../app_builder.dart';
import '../../build_result.dart';
import 'build_web_result.dart';

class AppBuilderWeb extends AppBuilder {
  @override
  String get platform => 'web';

  @override
  bool get isSupportedOnCurrentPlatform => true;

  @override
  BuildResultResolver get resultResolver => BuildWebResultResolver();
}
