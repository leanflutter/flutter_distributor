import 'package:args/command_runner.dart';
import 'package:fastforge/fastforge.dart';

/// Upgrade fastforge to the latest version
class CommandUpgrade extends Command {
  CommandUpgrade(this.fastforge);

  final Fastforge fastforge;

  @override
  String get name => 'upgrade';

  @override
  String get description => 'Upgrade your copy of Fastforge.';

  @override
  Future run() async {
    await fastforge.upgrade();
  }
}
