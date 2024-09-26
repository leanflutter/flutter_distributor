import 'dart:io';

import 'package:flutter_app_packager/src/api/app_package_maker.dart';
import 'package:flutter_app_packager/src/makers/deb/make_deb_config.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:shell_executor/shell_executor.dart';

class AppPackageMakerDeb extends AppPackageMaker {
  @override
  String get name => 'deb';
  @override
  String get platform => 'linux';
  @override
  bool get isSupportedOnCurrentPlatform => Platform.isLinux;
  @override
  String get packageFormat => 'deb';

  @override
  MakeConfigLoader get configLoader {
    return MakeDebConfigLoader()
      ..platform = platform
      ..packageFormat = packageFormat;
  }

  @override
  Future<MakeResult> make(MakeConfig config) {
    return _make(
      config.buildOutputDirectory,
      outputDirectory: config.outputDirectory,
      makeConfig: config as MakeDebConfig,
    );
  }

  Future<MakeResult> _make(
    Directory appDirectory, {
    required Directory outputDirectory,
    required MakeDebConfig makeConfig,
  }) async {
    final files = makeConfig.toFilesString();

    Directory packagingDirectory = makeConfig.packagingDirectory;

    /// Need to create following directories
    /// /DEBIAN
    /// /usr/share/$appBinaryName
    /// /usr/share/applications
    /// /usr/share/icons/hicolor/128x128/apps
    /// /usr/share/icons/hicolor/256x256/apps

    final debianDir = path.join(packagingDirectory.path, 'DEBIAN');
    final applicationsDir =
        path.join(packagingDirectory.path, 'usr/share/applications');
    final icon128Dir = path.join(
      packagingDirectory.path,
      'usr/share/icons/hicolor/128x128/apps',
    );
    final icon256Dir = path.join(
      packagingDirectory.path,
      'usr/share/icons/hicolor/256x256/apps',
    );
    final metainfoDir =
        path.join(packagingDirectory.path, 'usr/share/metainfo');
    final mkdirProcessResult = await $('mkdir', [
      '-p',
      debianDir,
      path.join(packagingDirectory.path, 'usr/share', makeConfig.appBinaryName),
      applicationsDir,
      if (makeConfig.metainfo != null) metainfoDir,
      if (makeConfig.icon != null) ...[icon128Dir, icon256Dir],
    ]);

    if (mkdirProcessResult.exitCode != 0) throw MakeError();

    if (makeConfig.icon != null) {
      final iconFile = File(makeConfig.icon!);
      if (!iconFile.existsSync()) {
        throw MakeError("provided icon ${makeConfig.icon} path wasn't found");
      }

      final icon128 = img.copyResize(
        img.decodeImage(iconFile.readAsBytesSync())!,
        width: 128,
        height: 128,
      );
      final icon128File =
          File(path.join(icon128Dir, '${makeConfig.appBinaryName}.png'));
      await icon128File.writeAsBytes(img.encodePng(icon128));

      final icon256 = img.copyResize(
        img.decodeImage(iconFile.readAsBytesSync())!,
        width: 128,
        height: 128,
      );
      final icon256File =
          File(path.join(icon256Dir, '${makeConfig.appBinaryName}.png'));
      await icon256File.writeAsBytes(img.encodePng(icon256));
    }
    if (makeConfig.metainfo != null) {
      final metainfoPath =
          path.join(Directory.current.path, makeConfig.metainfo!);
      final metainfoFile = File(metainfoPath);
      if (!metainfoFile.existsSync()) {
        throw MakeError("Metainfo $metainfoPath path wasn't found");
      }
      await metainfoFile.copy(
        path.join(
          metainfoDir,
          makeConfig.appBinaryName + path.extension(makeConfig.metainfo!, 2),
        ),
      );
    }

    // create & write the files got from makeConfig
    final controlFile = File(path.join(debianDir, 'control'));
    final postinstFile = File(path.join(debianDir, 'postinst'));
    final postrmFile = File(path.join(debianDir, 'postrm'));
    final desktopEntryFile =
        File(path.join(applicationsDir, '${makeConfig.appBinaryName}.desktop'));

    if (!controlFile.existsSync()) controlFile.createSync();
    if (!postinstFile.existsSync()) postinstFile.createSync();
    if (!postrmFile.existsSync()) postrmFile.createSync();
    if (!desktopEntryFile.existsSync()) desktopEntryFile.createSync();

    await controlFile.writeAsString(files['CONTROL']!);
    await desktopEntryFile.writeAsString(files['DESKTOP']!);
    await postinstFile.writeAsString(files['postinst']!);
    await postrmFile.writeAsString(files['postrm']!);

    // give execution permission to shell scripts
    await $('chmod', ['+x', postinstFile.path, postrmFile.path]);

    // copy the application binary to /usr/share/$appBinaryName
    await $('cp', [
      '-fr',
      '${appDirectory.path}/.',
      '${packagingDirectory.path}/usr/share/${makeConfig.appBinaryName}/',
    ]);

    ProcessResult processResult = await $('dpkg-deb', [
      '--build',
      '--root-owner-group',
      packagingDirectory.path,
      makeConfig.outputFile.path,
    ]);

    if (processResult.exitCode != 0) {
      throw MakeError();
    }

    packagingDirectory.deleteSync(recursive: true);
    return MakeResult(makeConfig);
  }
}
