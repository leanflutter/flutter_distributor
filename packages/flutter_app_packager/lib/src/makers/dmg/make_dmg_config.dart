import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class DmgWindowPosition {
  DmgWindowPosition({
    required this.x,
    required this.y,
  });

  factory DmgWindowPosition.fromJson(Map<String, dynamic> json) {
    return DmgWindowPosition(
      x: json['x'],
      y: json['y'],
    );
  }

  final num x;
  final num y;

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}

class DmgWindowSize {
  DmgWindowSize({
    required this.width,
    required this.height,
  });

  factory DmgWindowSize.fromJson(Map<String, dynamic> json) {
    return DmgWindowSize(
      width: json['width'],
      height: json['height'],
    );
  }
  final num width;
  final num height;

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }
}

class DmgWindow {
  DmgWindow({
    this.position,
    this.size,
  });

  factory DmgWindow.fromJson(Map<String, dynamic> json) {
    return DmgWindow(
      position: DmgWindowPosition.fromJson(json['position']),
      size: DmgWindowSize.fromJson(json['size']),
    );
  }
  final DmgWindowPosition? position;
  final DmgWindowSize? size;

  Map<String, dynamic> toJson() {
    return {
      'position': position?.toJson(),
      'size': size?.toJson(),
    }..removeWhere((key, value) => value == null);
  }
}

class DmgCodeSign {
  DmgCodeSign({
    required this.signingIdentity,
    this.identifier,
  });

  factory DmgCodeSign.fromJson(Map<String, dynamic> json) {
    return DmgCodeSign(
      signingIdentity: json['signing-identity'],
      identifier: json['identifier'],
    );
  }
  final String signingIdentity;
  final String? identifier;

  Map<String, dynamic> toJson() {
    return {
      'signing-identity': signingIdentity,
      'identifier': identifier,
    }..removeWhere((key, value) => value == null);
  }
}

class DmgContent {
  DmgContent({
    required this.x,
    required this.y,
    required this.type,
    required this.path,
    this.name,
  });

  factory DmgContent.fromJson(Map<String, dynamic> json) {
    return DmgContent(
      x: json['x'],
      y: json['y'],
      type: json['type'],
      path: json['path'],
      name: json['name'],
    );
  }
  final num x;
  final num y;
  final String type;
  final String path;
  final String? name;

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'type': type,
      'path': path,
      'name': name,
    }..removeWhere((key, value) => value == null);
  }
}

class MakeDmgConfig extends MakeConfig {
  MakeDmgConfig({
    required this.title,
    this.icon,
    this.background,
    this.backgroundColor,
    this.iconSize,
    this.format,
    required this.contents,
    this.codeSign,
  });

  factory MakeDmgConfig.fromJson(Map<String, dynamic> json) {
    List<DmgContent> contents = (json['contents'] as List)
        .map((item) => DmgContent.fromJson(item))
        .toList();

    return MakeDmgConfig(
      title: json['title'],
      icon: json['icon'],
      background: json['background'],
      backgroundColor: json['backgroundColor'],
      iconSize: json['icon-size'],
      format: json['format'],
      contents: contents,
      codeSign: json['code-sign'] != null
          ? DmgCodeSign.fromJson(json['code-sign'])
          : null,
    );
  }
  final String title;
  final String? icon;
  final String? background;
  final String? backgroundColor;
  final int? iconSize;
  final String? format;
  final List<DmgContent> contents;
  final DmgCodeSign? codeSign;

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon,
      'background': background,
      'backgroundColor': backgroundColor,
      'icon-size': iconSize,
      'format': format,
      'contents': contents.map((e) => e.toJson()).toList(),
      'code-sign': codeSign?.toJson(),
    }..removeWhere((key, value) => value == null);
  }
}

class MakeDmgConfigLoader extends DefaultMakeConfigLoader {
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
    return MakeDmgConfig.fromJson(map).copyWith(baseMakeConfig);
  }
}
