import 'dart:io';

import 'app_builder.dart';

class AppBuilderLinux extends AppBuilder {
  @override
  String get platform => 'linux';

  @override
  bool get isSupportedOnCurrentPlatform => Platform.isLinux;

  @override
  Directory get outputDirectory {
    String arch = 'x64';
    ProcessResult processResult = Process.runSync('uname', ['-m']);
    if ('${processResult.stdout}'.trim() == 'aarch64') {
      arch = 'arm64';
    }
    return Directory('build/linux/${arch}/release/bundle');
  }
}
