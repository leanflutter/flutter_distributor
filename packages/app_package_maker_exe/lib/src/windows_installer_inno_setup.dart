import 'dart:io';

import 'windows_installer.dart';

class WindowsInstallerInnoSetup extends WindowsInstaller {
  @override
  Future<void> compile({required Directory packagingDirectory}) async {
    Process.runSync('cp', [
      '-fr',
      'windows/packaging/exe/InnoSetup.iss',
      '${packagingDirectory.path}.iss',
    ]);

    File issFile = File('${packagingDirectory.path}.iss');

    String issFileContent = issFile.readAsStringSync();
    issFileContent = issFileContent.replaceAll(
      '#define MyAppPackagingDir ""',
      '#define MyAppPackagingDir "${packagingDirectory.path.split('/').last}"',
    );
    issFileContent = issFileContent.replaceAll(
      '#define MyAppOutputBaseFilename ""',
      '#define MyAppOutputBaseFilename "${packagingDirectory.path.split('/').last}"',
    );

    issFile.writeAsStringSync(issFileContent);
    Process.runSync('iscc', [
      '${packagingDirectory.path}.iss',
    ]);
    issFile.deleteSync(recursive: true);
  }
}
