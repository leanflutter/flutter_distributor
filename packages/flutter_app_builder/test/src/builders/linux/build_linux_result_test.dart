import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/builders/linux/build_linux_result.dart';
import 'package:test/test.dart';

void main() {
  group('linux result', () {
    test('profile mode', () {
      final r = BuildLinuxResult(
        BuildConfig(
          arguments: {'profile': true},
        ),
      );
      r.arch = 'x64';
      expect(r.outputDirectory.path, 'build/linux/x64/profile/bundle');
      r.arch = 'arm64';
      expect(r.outputDirectory.path, 'build/linux/arm64/profile/bundle');
    });
    test('release mode', () {
      final r = BuildLinuxResult(
        BuildConfig(),
      );
      r.arch = 'x64';
      expect(r.outputDirectory.path, 'build/linux/x64/release/bundle');
      r.arch = 'arm64';
      expect(r.outputDirectory.path, 'build/linux/arm64/release/bundle');
    });
  });
}
