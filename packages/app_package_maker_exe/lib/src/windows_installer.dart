import 'dart:io';

abstract class WindowsInstaller {
  Future<void> compile({
    required Directory packagingDirectory,
  });
}
