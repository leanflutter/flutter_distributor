import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';

class CommandUpgrade extends Command {
  final FlutterDistributor distributor;

  CommandUpgrade(this.distributor);

  @override
  String get name => 'upgrade';

  @override
  String get description => 'Upgrade your copy of Flutter Distributor.';

  @override
  Future run() async {
    await distributor.upgrade();
  }
}
