import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_app_packager/src/api/app_package_maker.dart';
import 'package:shell_executor/shell_executor.dart';

class AppPackageMakerZip extends AppPackageMaker {
  AppPackageMakerZip(String platform) {
    _platform = platform;
  }

  late String _platform;

  @override
  String get name => 'zip';
  @override
  String get platform => _platform;
  @override
  String get packageFormat => 'zip';

  @override
  Future<MakeResult> make(MakeConfig config) async {
    Directory appDirectory = config.buildOutputDirectory;
    Directory packagingDirectory = appDirectory;

    if (platform == 'macos') {
      // 由于使用 archive 在压缩时会导致 app 损坏，所以这里使用 7z 压缩。
      packagingDirectory = config.packagingDirectory;
      File appFile = appDirectory
          .listSync()
          .where((e) => e.path.endsWith('.app'))
          .map((e) => File(e.path))
          .first;
      await $('cp', ['-RH', appFile.path, packagingDirectory.path]);
      await $(
        '7z',
        ['a', config.outputFile.path, './${packagingDirectory.path}/*.app'],
      );
      packagingDirectory.deleteSync(recursive: true);
    } else {
      final zipFileEncoder = ZipFileEncoder();
      zipFileEncoder.zipDirectory(
        packagingDirectory,
        filename: config.outputFile.path,
        followLinks: true,
      );
    }
    return resultResolver.resolve(config);
  }
}
