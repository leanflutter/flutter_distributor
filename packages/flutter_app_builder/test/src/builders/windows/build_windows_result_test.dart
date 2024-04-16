import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/builders/windows/build_windows_result.dart';
import 'package:flutter_app_builder/src/commands/flutter.dart';
import 'package:test/test.dart';

void main() {
  group('windows result', () {
    test('profile mode', () {
      final r = BuildWindowsResult(
        BuildConfig(
          arguments: {'profile': true},
        ),
      );
      r.flutterVersion = const FlutterVersion(flutterVersion: '3.16.0');
      expect(r.outputDirectory.path, 'build/windows/x64/runner/Profile');
    });
    test('profile mode (less 3.15.0)', () {
      final r = BuildWindowsResult(
        BuildConfig(
          arguments: {'profile': true},
        ),
      );
      r.flutterVersion = const FlutterVersion(flutterVersion: '3.10.0');
      expect(r.outputDirectory.path, 'build/windows/runner/Profile');
    });
    test('release mode', () {
      final r = BuildWindowsResult(
        BuildConfig(),
      );
      r.flutterVersion = const FlutterVersion(flutterVersion: '3.16.0');
      expect(r.outputDirectory.path, 'build/windows/x64/runner/Release');
    });
    test('release mode (less 3.15.0)', () {
      final r = BuildWindowsResult(
        BuildConfig(),
      );
      r.flutterVersion = const FlutterVersion(flutterVersion: '3.10.0');
      expect(r.outputDirectory.path, 'build/windows/runner/Release');
    });
  });
}
