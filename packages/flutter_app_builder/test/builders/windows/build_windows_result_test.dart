import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/builders/windows/build_windows_result.dart';
import 'package:test/test.dart';

void main() {
  group('windows result', () {
    test('profile mode', () {
      final r = BuildWindowsResult(
        BuildConfig(mode: BuildMode.profile),
      );
      expect(r.outputDirectory.path, 'build/windows/runner/Profile');
    });
    test('release mode', () {
      final r = BuildWindowsResult(
        BuildConfig(),
      );
      expect(r.outputDirectory.path, 'build/windows/runner/Release');
    });
  });
}
