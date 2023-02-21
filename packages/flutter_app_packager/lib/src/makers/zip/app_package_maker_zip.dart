import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:archive/archive_io.dart';
import 'package:shell_executor/shell_executor.dart';

class AppPackageMakerZip extends AppPackageMaker {
  AppPackageMakerZip(String platform) {
    this._platform = platform;
  }

  late String _platform;

  String get name => 'zip';
  String get platform => _platform;
  String get packageFormat => 'zip';

  @override
  Future<MakeResult> make(MakeConfig config) async {
    Directory appDirectory = config.buildOutputDirectory;
    Directory packagingDirectory = appDirectory;

    if (platform == 'macos') {
      packagingDirectory = config.packagingDirectory;
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
      filename: config.outputFile.path,
      followLinks: true,
    );
    packagingDirectory.deleteSync(recursive: true);

    return resultResolver.resolve(config);
  }
}
