import 'package:flutter_app_builder/src/commands/flutter.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterVersion', () {
    test('isGreaterOrEqual#1', () {
      final v3100 = FlutterVersion(
        flutterVersion: '3.10.0',
      );
      expect(v3100.isGreaterOrEqual('3.3.10'), true);
      expect(v3100.isGreaterOrEqual('3.10.0'), true);
      expect(v3100.isGreaterOrEqual('3.10.1'), false);
    });
    test('isGreaterOrEqual#2', () {
      final v3150 = FlutterVersion(
        flutterVersion: '3.15.0-15.2.pre',
      );
      expect(v3150.isGreaterOrEqual('3.3.10'), true);
      expect(v3150.isGreaterOrEqual('3.15.0'), true);
      expect(v3150.isGreaterOrEqual('3.16.1'), false);
    });
  });
}
