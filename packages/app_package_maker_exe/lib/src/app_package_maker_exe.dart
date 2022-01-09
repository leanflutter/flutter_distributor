import 'dart:convert';
import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:path/path.dart' as p;

import 'make_exe_config.dart';
import 'create_setup_script_file.dart';

class AppPackageMakerExe extends AppPackageMaker {
  String get name => 'exe';
  String get platform => 'windows';
  String get packageFormat => 'exe';

  bool get isSupportedOnCurrentPlatform => Platform.isWindows;

  @override
  Future<MakeConfig> loadMakeConfig() async {
    final map = loadMakeConfigYaml('windows/packaging/exe/make_config.yaml');
    return MakeExeConfig.fromJson(map)
      ..isInstaller = true
      ..platform = platform
      ..packageFormat = packageFormat;
  }

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    String? flavor,
    void Function(List<int> data)? onProcessStdOut,
    void Function(List<int> data)? onProcessStdErr,
  }) async {
    MakeConfig makeConfig = await loadMakeConfig()
      ..outputDirectory = outputDirectory;
    Directory packagingDirectory = makeConfig.packagingDirectory;

    Directory innoSetupDirectory =
        Directory('C:\\Program Files (x86)\\Inno Setup 6');

    if (!innoSetupDirectory.existsSync()) {
      throw Exception('`Inno Setup 6` was not installed.');
    }

    Process.runSync(
      'cp',
      [
        '-R',
        '${appDirectory.path}/*',
        packagingDirectory.path,
      ],
    );

    File setupScriptFile =
        await createSetupScriptFile(makeConfig as MakeExeConfig);

    Process process = await Process.start(
      p.join(innoSetupDirectory.path, 'ISCC.exe'),
      [setupScriptFile.path],
    );
    process.stdout.listen(onProcessStdOut);
    process.stderr.listen(onProcessStdErr);

    int exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw MakeError();
    }

    packagingDirectory.deleteSync(recursive: true);
    setupScriptFile.deleteSync(recursive: true);

    return MakeResult(makeConfig);
  }
}
