import 'dart:io';

import 'package:flutter_app_packager/src/makers/exe/inno_setup/inno_setup_script.dart';
import 'package:path/path.dart' as p;
import 'package:shell_executor/shell_executor.dart';

class InnoSetupCompiler {
  Future<bool> compile(InnoSetupScript script) async {
    Directory innoSetupDirectory =
        Directory('C:\\Program Files (x86)\\Inno Setup 6');

    if (!innoSetupDirectory.existsSync()) {
      throw Exception('`Inno Setup 6` was not installed.');
    }

    File file = await script.createFile();

    ProcessResult processResult = await $(
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
