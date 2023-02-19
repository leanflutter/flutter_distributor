import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/builders/web/build_web_result.dart';
import 'package:test/test.dart';

void main() {
  group('web result', () {
    test('profile mode', () {
      final r = BuildWebResult(
        BuildConfig(mode: BuildMode.profile),
      );
      expect(r.outputDirectory.path, 'build/web');
    });
    test('release mode', () {
      final r = BuildWebResult(
        BuildConfig(),
      );
      expect(r.outputDirectory.path, 'build/web');
    });
  });
}
