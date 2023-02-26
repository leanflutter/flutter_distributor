import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/builders/android/build_android_result.dart';
import 'package:test/test.dart';

void main() {
  group('android aab result', () {
    test('profile mode', () {
      final r = BuildAndroidResult.aab(
        BuildConfig(
          arguments: {'profile': true},
        ),
      );
      expect(r.outputDirectory.path, 'build/app/outputs/bundle/profile');
    });
    test('profile mode + flavor', () {
      final r = BuildAndroidResult.aab(
        BuildConfig(
          arguments: {'profile': true, 'flavor': 'dev'},
        ),
      );
      expect(r.outputDirectory.path, 'build/app/outputs/bundle/devProfile');
    });
    test('release mode', () {
      final r = BuildAndroidResult.aab(
        BuildConfig(),
      );
      expect(r.outputDirectory.path, 'build/app/outputs/bundle/release');
    });
    test('release mode + flavor', () {
      final r = BuildAndroidResult.aab(
        BuildConfig(
          arguments: {'flavor': 'dev'},
        ),
      );
      expect(r.outputDirectory.path, 'build/app/outputs/bundle/devRelease');
    });
  });
  group('android apk result', () {
    test('profile mode', () {
      final r = BuildAndroidResult.apk(
        BuildConfig(
          arguments: {'profile': true},
        ),
      );
      expect(r.outputDirectory.path, 'build/app/outputs/apk/profile');
    });
    test('profile mode + flavor', () {
      final r = BuildAndroidResult.apk(
        BuildConfig(
          arguments: {'profile': true, 'flavor': 'dev'},
        ),
      );
      expect(r.outputDirectory.path, 'build/app/outputs/apk/dev/profile');
    });
    test('release mode', () {
      final r = BuildAndroidResult.apk(
        BuildConfig(),
      );
      expect(r.outputDirectory.path, 'build/app/outputs/apk/release');
    });

    test('release mode + flavor', () {
      final r = BuildAndroidResult.apk(
        BuildConfig(
          arguments: {'flavor': 'dev'},
        ),
      );
      String dirPath = r.outputDirectory.path;
      expect(dirPath, 'build/app/outputs/apk/dev/release');
    });
  });
}
