import 'dart:io';

import 'package:flutter_app_packager/src/api/make_config.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:test/test.dart';

void main() {
  group('MakeConfig', () {
    test('#1', () {
      final makeConfig = MakeConfig()
        ..buildMode = 'release'
        ..buildOutputDirectory = Directory('build')
        ..buildOutputFiles = []
        ..platform = 'android'
        ..packageFormat = 'apk'
        ..outputDirectory = Directory('dist/')
        ..pubspec = Pubspec(
          'test_app',
          version: Version.parse('1.0.0'),
        );
      expect(
        makeConfig.outputArtifactPath,
        'dist/1.0.0/test_app-1.0.0-android.apk',
      );
    });
    test('#2', () {
      final makeConfig = MakeConfig()
        ..buildMode = 'release'
        ..buildOutputDirectory = Directory('build')
        ..buildOutputFiles = []
        ..platform = 'android'
        ..packageFormat = 'apk'
        ..outputDirectory = Directory('dist/')
        ..pubspec = Pubspec(
          'test_app',
          version: Version.parse('1.0.0+1'),
        );
      expect(
        makeConfig.outputArtifactPath,
        'dist/1.0.0+1/test_app-1.0.0+1-android.apk',
      );
    });
  });
}
