import 'package:shell_executor/src/utils/path_expansion.dart';
import 'package:test/test.dart';

void main() {
  Map<String, String> environment = {
    'HOME': '/home/root',
  };
  group('pathExpansion', () {
    test('~/Documents', () {
      final path = pathExpansion('~/Documents', environment);
      expect(path, '/home/root/Documents');
    });
    test('\$HOME/Documents', () {
      final r = pathExpansion('\$HOME/Documents', environment);
      expect(r, '/home/root/Documents');
    });
    test('\${HOME}/Documents', () {
      final r = pathExpansion('\${HOME}/Documents', environment);
      expect(r, '/home/root/Documents');
    });
  });
}
