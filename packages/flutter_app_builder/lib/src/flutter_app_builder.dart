import 'app_builder_android.dart';
import 'app_builder_ios.dart';
import 'app_builder_linux.dart';
import 'app_builder_macos.dart';
import 'app_builder_web.dart';
import 'app_builder_windows.dart';
import 'app_builder.dart';

class FlutterAppBuilder {
  final List<AppBuilder> _builders = [
    AppBuilderAndroid(),
    AppBuilderIos(),
    AppBuilderLinux(),
    AppBuilderMacOs(),
    AppBuilderWeb(),
    AppBuilderWindows(),
  ];

  Future<BuildResult> build({
    required String platform,
    String? entryPoint,
    String? flavor,
    String? target,
    bool verbose = false,
  }) async {
    AppBuilder builder = _builders.firstWhere((e) => e.platform == platform);
    return await builder.build(
      entryPoint: entryPoint,
      flavor: flavor,
      target: target,
      verbose: verbose,
    );
  }
}
