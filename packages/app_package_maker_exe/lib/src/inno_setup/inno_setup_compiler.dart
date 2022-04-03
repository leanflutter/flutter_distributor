import 'dart:io';
import 'package:path/path.dart' as p;

import './inno_setup_script.dart';

class InnoSetupCompiler {
  Future<bool> compile(
    InnoSetupScript script, {
    void Function(List<int> data)? onProcessStdOut,
    void Function(List<int> data)? onProcessStdErr,
  }) async {
    Directory innoSetupDirectory =
        Directory('C:\\Program Files (x86)\\Inno Setup 6');

    if (!innoSetupDirectory.existsSync()) {
      throw Exception('`Inno Setup 6` was not installed.');
    }

    File file = await script.createFile();

    Process process = await Process.start(
      p.join(innoSetupDirectory.path, 'ISCC.exe'),
      [file.path],
    );
    process.stdout.listen(onProcessStdOut);
    process.stderr.listen(onProcessStdErr);

    int exitCode = await process.exitCode;
    if (exitCode != 0) {
      return false;
    }

    file.deleteSync(recursive: true);
    return true;
  }
}
