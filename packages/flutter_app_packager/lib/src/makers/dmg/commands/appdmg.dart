import 'package:shell_executor/shell_executor.dart';

class _AppDmg extends Command {
  @override
  String get executable => 'appdmg';

  @override
  Future<void> install() async {
    await $('pnpm', 'install -g appdmg'.split(' '));
  }
}

final appdmg = _AppDmg();
