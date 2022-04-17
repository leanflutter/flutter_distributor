import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:archive/archive_io.dart';

class AppPackageMakerZip extends AppPackageMaker {
  late String _platform;

  AppPackageMakerZip(String platform) {
    this._platform = platform;
  }

  String get name => 'zip';
  String get platform => _platform;
  String get packageFormat => 'zip';

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    Map<String, dynamic>? makeArguments,
    void Function(List<int> data)? onProcessStdOut,
    void Function(List<int> data)? onProcessStdErr,
  }) async {
    MakeConfig makeConfig = await loadMakeConfig(
      outputDirectory,
      makeArguments,
    );

    if (platform == 'windows') {
      final zipFileEncoder = ZipFileEncoder();
      zipFileEncoder.zipDirectory(
        appDirectory,
        filename: makeConfig.outputFile.path,
      );
    } else {
      String filter = platform == 'macos' ? '*.app' : '*';
      Process.runSync('7z', [
        'a',
        makeConfig.outputFile.path,
        './${appDirectory.path}/$filter',
      ]);
    }
    return MakeResult(makeConfig);
  }
}
