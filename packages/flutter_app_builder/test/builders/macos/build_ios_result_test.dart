import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/builders/macos/build_macos_result.dart';
import 'package:test/test.dart';

void main() {
  group('macos result', () {
    test('profile mode', () {
      final r = BuildMacOsResult(
        BuildConfig(mode: BuildMode.profile),
      );
      expect(r.outputDirectory.path, 'build/macos/Build/Products/Profile');
    });
    test('release mode', () {
      final r = BuildMacOsResult(
        BuildConfig(),
      );
      expect(r.outputDirectory.path, 'build/macos/Build/Products/Release');
    });
  });
}
