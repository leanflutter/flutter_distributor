import 'package:flutter_app_builder/src/build_config.dart';
import 'package:test/test.dart';

void main() {
  group('build config', () {
    test('mode', () {
      final profileConfig = BuildConfig(
        arguments: {'profile': true},
      );
      expect(profileConfig.mode, BuildMode.profile);
      final releaseCconfig = BuildConfig();
      expect(releaseCconfig.mode, BuildMode.release);
    });
    test('flavor', () {
      final config = BuildConfig(
        arguments: {'flavor': 'dev'},
      );
      expect(config.flavor, 'dev');
    });
  });
}
