import 'package:shell_executor/shell_executor.dart';

class _RpmBuild extends Command {
  @override
  String get executable => 'rpmbuild';

  @override
  Future<void> install() {
    return Future.value();
  }
}

final rpmbuild = _RpmBuild();
