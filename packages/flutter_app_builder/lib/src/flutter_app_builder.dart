import 'app_builder_android.dart';
import 'app_builder_ios.dart';
import 'app_builder_linux.dart';
import 'app_builder_macos.dart';
import 'app_builder_web.dart';
import 'app_builder_windows.dart';
import 'app_builder.dart';

class FlutterAppBuilder {
  final List<AppBuilder> _builders = [
    AppBuilderAndroid.aab(),
    AppBuilderAndroid.apk(),
    AppBuilderIos(),
    AppBuilderLinux(),
    AppBuilderMacOs(),
    AppBuilderWeb(),
    AppBuilderWindows(),
  ];

  Future<BuildResult> build(
    String platform,
    String target, {
    required bool cleanBeforeBuild,
    required Map<String, dynamic> buildArguments,
    required void Function(List<int> data) onProcessStdOut,
    required void Function(List<int> data) onProcessStdErr,
  }) async {
    AppBuilder builder = _builders.firstWhere(
      (e) {
        if (e.platform == platform && e is AppBuilderAndroid) {
          return e.target == target;
        }
        return e.platform == platform;
      },
    );

    if (!builder.isSupportedOnCurrentPlatform) {
      throw UnsupportedError(
          '${builder.runtimeType} is not supported on the current platform');
    }

    return await builder.build(
      target: target,
      cleanBeforeBuild: cleanBeforeBuild,
      buildArguments: buildArguments,
      onProcessStdOut: onProcessStdOut,
      onProcessStdErr: onProcessStdErr,
    );
  }
}
