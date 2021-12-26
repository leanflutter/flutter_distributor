import 'package:args/command_runner.dart';
import 'package:flutter_distributor/flutter_distributor.dart';

class CommandInit extends Command {
  final FlutterDistributor distributor;

  CommandInit(this.distributor);

  @override
  String get name => 'init';

  @override
  String get description => '';

  @override
  Future run() async {
    await distributor.init();
  }
}
