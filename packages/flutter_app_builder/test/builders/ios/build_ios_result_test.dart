import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/builders/ios/build_ios_result.dart';
import 'package:test/test.dart';

void main() {
  group('ios result', () {
    test('profile mode', () {
      final r = BuildIosResult(
        BuildConfig(mode: BuildMode.profile),
      );
      expect(r.outputDirectory.path, 'build/ios/ipa');
    });
    test('release mode', () {
      final r = BuildIosResult(
        BuildConfig(),
      );
      expect(r.outputDirectory.path, 'build/ios/ipa');
    });
  });
}
