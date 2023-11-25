import 'package:flutter_app_builder/src/commands/flutter.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterVersion', () {
    test('isGreaterOrEqual', () {
      final v3100 = FlutterVersion(
        flutterVersion: '3.10.0',
      );
      expect(v3100.isGreaterOrEqual('3.3.10'), true);
      expect(v3100.isGreaterOrEqual('3.10.0'), true);
      expect(v3100.isGreaterOrEqual('3.10.1'), false);
    });
  });
}
