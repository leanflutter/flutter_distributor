// ignore_for_file: flutter_style_todo,todo

import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:path/path.dart' as path;

/// this how the config should look like
/// appId: lol.itsanapp.question
// # relative path to icon
/// icon: assets/logo.png
// # this is the default script command
/// script:
///   - rm -rf build/AppDir || true
///   - cp -r build/linux/x64/release/bundle AppDir
///   - mkdir -p build/AppDir/usr/share/icons/hicolor/64x64/apps/
///   - cp assets/spotube-logo.png build/AppDir/usr/share/icons/hicolor/64x64/apps/
// # name of [apt] packages that should be included
/// include:
///   - libkeybinder-3.0-0
/// exclude:
// # by default following dependencies will be excluded
///   - libx11-6
///   - libgtk-3-0
///   - libglib2.0-0
///   - libc6
// # toggle for excluding those flutter system dependencies by default
// # @default (true)
/// default_excludes: true
/// files:
// # file include/exclude
///   include: []
// # by default these will be excluded
///   exclude:
///     - usr/share/man
///     - usr/share/doc/*/README.*
///     - usr/share/doc/*/changelog.*
///     - usr/share/doc/*/NEWS.*
///   - usr/share/doc/*/TODO.*
//    # toggle for excluding those directories by default
//    # @default (true)
///   default_excludes: true

const defaultScript = [
  'rm -rf AppDir || true',
  'cp -r build/linux/x64/release/bundle AppDir',
  'mkdir -p AppDir/usr/share/icons/hicolor/64x64/apps/',
];

const defaultExclude = [
  'libx11-6',
  'libgtk-3-0',
  'libglib2.0-0',
  'libc6',
];

const defaultExcludeFiles = [
  'usr/share/man',
  'usr/share/doc/*/README.*',
  'usr/share/doc/*/changelog.*',
  'usr/share/doc/*/NEWS.*',
];

class MakeAppImageConfig extends MakeConfig {
  MakeAppImageConfig({
    List<String> script = const [],
    List<String> exclude = const [],
    List<String> exclude_files = const [],
    required this.appId,
    required this.include,
    required this.include_files,
    this.icon,
    this.default_excludes = true,
    this.default_excludes_files = true,
  })  : _script = script,
        _exclude = exclude,
        _exclude_files = exclude_files;

  factory MakeAppImageConfig.fromJson(Map<String, dynamic> map) {
    return MakeAppImageConfig(
      appId: map['appId'],
      icon: map['icon'],
      script: List.castFrom<dynamic, String>(map['script'] ?? []),
      include: List.castFrom<dynamic, String>(map['include'] ?? []),
      exclude: List.castFrom<dynamic, String>(map['exclude'] ?? []),
      default_excludes: map['default_excludes'] ?? true,
      include_files:
          List.castFrom<dynamic, String>(map['files']?['include'] ?? []),
      exclude_files:
          List.castFrom<dynamic, String>(map['files']?['exclude'] ?? []),
      default_excludes_files: map['files']?['default_excludes'] ?? false,
    );
  }

  String appId;
  String? icon;
  List<String> _script;
  List<String> include;
  List<String> _exclude;
  bool default_excludes;
  List<String> include_files;
  List<String> _exclude_files;
  bool default_excludes_files;

  List<String> get script => [
        ...defaultScript,
        if (icon != null) 'cp $icon AppDir/usr/share/icons/hicolor/',
        ..._script
      ];
  List<String> get exclude => [
        ...(default_excludes ? defaultExclude : []),
        ..._exclude,
      ];
  List<String> get exclude_files => [
        ...(default_excludes_files ? defaultExcludeFiles : []),
        ..._exclude_files,
      ];

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'script': script,
      'AppDir': {
        'path': 'AppDir',
        'app_info': {
          'id': appId,
          if (icon != null) 'icon': path.basenameWithoutExtension(icon!),
          'name': appName,
          'version': appVersion.toString(),
          'exec': appName,
          'exec_args': '\$@',
        },
        'apt': {
          'arch': 'amd64',
          'allow_unauthenticated': true,
          'sources': [
            {
              'sourceline':
                  'deb http://archive.ubuntu.com/ubuntu/ hirsute main restricted'
            },
            {
              'sourceline':
                  'deb http://archive.ubuntu.com/ubuntu/ hirsute-updates main restricted'
            },
            {
              'sourceline':
                  'deb http://archive.ubuntu.com/ubuntu/ hirsute universe'
            },
            {
              'sourceline':
                  'deb http://archive.ubuntu.com/ubuntu/ hirsute-updates universe'
            },
            {
              'sourceline':
                  'deb http://archive.ubuntu.com/ubuntu/ hirsute multiverse'
            },
            {
              'sourceline':
                  'deb http://archive.ubuntu.com/ubuntu/ hirsute-updates multiverse'
            },
            {
              'sourceline':
                  'deb http://archive.ubuntu.com/ubuntu/ hirsute-backports main           restricted universe multiverse'
            },
            {
              'sourceline':
                  'deb http://security.ubuntu.com/ubuntu hirsute-security main restricted'
            },
            {
              'sourceline':
                  'deb http://security.ubuntu.com/ubuntu hirsute-security universe'
            },
            {
              'sourceline':
                  'deb http://security.ubuntu.com/ubuntu hirsute-security multiverse'
            },
          ],
          'include': include,
          'exclude': exclude,
        },
        'files': {
          'include': include_files,
          'exclude': exclude_files,
        },
      },
      'AppImage': {
        'arch': 'x86_64',
        'update-information': 'guess',
      }
    }..removeWhere((key, value) => value == null);
  }
}

class MakeAppImageConfigLoader extends DefaultMakeConfigLoader {
  @override
  MakeConfig load(
    Map<String, dynamic>? arguments,
    Directory outputDirectory, {
    required Directory buildOutputDirectory,
    required List<File> buildOutputFiles,
  }) {
    final baseMakeConfig = super.load(
      arguments,
      outputDirectory,
      buildOutputDirectory: buildOutputDirectory,
      buildOutputFiles: buildOutputFiles,
    );
    final map = loadMakeConfigYaml(
      '$platform/packaging/$packageFormat/make_config.yaml',
    );
    return MakeAppImageConfig.fromJson(map).copyWith(baseMakeConfig);
  }
}
