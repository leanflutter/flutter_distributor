import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:archive/archive_io.dart';
import 'package:shell_executor/shell_executor.dart';

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
  }) async {
    MakeConfig makeConfig = await loadMakeConfig(
      outputDirectory,
      makeArguments,
    );

    Directory packagingDirectory = appDirectory;

    if (platform == 'macos') {
      packagingDirectory = makeConfig.packagingDirectory;
      File appFile = appDirectory
          .listSync()
          .where((e) => e.path.endsWith('.app'))
          .map((e) => File(e.path))
          .first;

      await $('cp', ['-RH', appFile.path, packagingDirectory.path]);
    }

    final zipFileEncoder = ZipFileEncoder();
    zipFileEncoder.zipDirectory(
      packagingDirectory,
      filename: makeConfig.outputFile.path,
      followLinks: true,
    );

    packagingDirectory.deleteSync(recursive: true);

    return MakeResult(makeConfig);
  }
}
