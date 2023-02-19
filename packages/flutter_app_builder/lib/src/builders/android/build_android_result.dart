import 'dart:io';

import 'package:flutter_app_builder/src/build_config.dart';
import 'package:flutter_app_builder/src/build_result.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:recase/recase.dart';

class BuildAndroidResultResolver extends BuildResultResolver {
  final String target;

  BuildAndroidResultResolver(
    this.target,
  ) : _actualResultResolver = target == 'aab'
            ? _BuildAndroidAabResultResolver()
            : _BuildAndroidApkResultResolver();

  late BuildResultResolver _actualResultResolver;

  factory BuildAndroidResultResolver.aab() {
    return BuildAndroidResultResolver('aab');
  }

  factory BuildAndroidResultResolver.apk() {
    return BuildAndroidResultResolver('apk');
  }

  @override
  BuildResult resolve(BuildConfig config) {
    return _actualResultResolver.resolve(config);
  }
}

class BuildAndroidResult extends BuildResult {
  final String target;

  BuildAndroidResult(this.target, BuildConfig config)
      : _actualResult = target == 'aab'
            ? _BuildAndroidAabResult(config)
            : _BuildAndroidApkResult(config),
        super(config);

  factory BuildAndroidResult.aab(BuildConfig config) {
    return BuildAndroidResult(
      'aab',
      config,
    );
  }

  factory BuildAndroidResult.apk(BuildConfig config) {
    return BuildAndroidResult('apk', config);
  }

  late BuildResult _actualResult;

  @override
  Directory get outputDirectory => _actualResult.outputDirectory;
}

class _BuildAndroidAabResultResolver extends BuildResultResolver {
  @override
  BuildResult resolve(BuildConfig config) {
    final r = _BuildAndroidAabResult(config);
    final String pattern = [
      '${r.outputDirectory.path}/**',
      config.flavor != null ? '-${config.flavor}' : '',
      '-${config.mode.name}.aab',
    ].join();
    r.outputFiles = Glob(pattern).listSync().map((e) => File(e.path)).toList();
    return r;
  }
}

class _BuildAndroidAabResult extends BuildResult {
  _BuildAndroidAabResult(BuildConfig config) : super(config);

  @override
  Directory get outputDirectory {
    String buildMode = config.mode.name;
    String path = 'build/app/outputs/bundle/${buildMode}';
    if (config.flavor != null) {
      buildMode = ReCase(buildMode).sentenceCase;
      path = 'build/app/outputs/bundle/${config.flavor}$buildMode';
    }
    return Directory(path);
  }
}

class _BuildAndroidApkResultResolver extends BuildResultResolver {
  @override
  BuildResult resolve(BuildConfig config, {Duration? duration}) {
    final r = _BuildAndroidApkResult(config)..duration = duration;
    final String pattern = [
      '${r.outputDirectory.path}/**',
      config.flavor != null ? '-${config.flavor}' : '',
      '-${config.mode.name}.apk',
    ].join();
    r.outputFiles = Glob(pattern).listSync().map((e) => File(e.path)).toList();
    return r;
  }
}

class _BuildAndroidApkResult extends BuildResult {
  _BuildAndroidApkResult(BuildConfig config) : super(config);

  @override
  Directory get outputDirectory {
    String buildMode = config.mode.name;
    String path = 'build/app/outputs/apk/${buildMode}';
    if (config.flavor != null) {
      path = 'build/app/outputs/apk/${config.flavor}/$buildMode';
    }
    return Directory(path);
  }
}
