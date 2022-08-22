import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:shell_executor/shell_executor.dart';

import './inno_setup_script.dart';

ShellExecutor get _shellExecutor => ShellExecutor.global;

class InnoSetupCompiler {
  Future<bool> compile(InnoSetupScript script) async {
    Directory innoSetupDirectory =
        Directory('C:\\Program Files (x86)\\Inno Setup 6');

    if (!innoSetupDirectory.existsSync()) {
      throw Exception('`Inno Setup 6` was not installed.');
    }

    File file = await script.createFile();

    ProcessResult processResult = await _shellExecutor.exec(
      p.join(innoSetupDirectory.path, 'ISCC.exe'),
      [file.path],
    );

    if (processResult.exitCode != 0) {
      return false;
    }

    file.deleteSync(recursive: true);
    return true;
  }
}
