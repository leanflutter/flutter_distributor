import 'package:app_package_maker/app_package_maker.dart';

class DmgWindowPosition {
  final num x;
  final num y;

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

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}

class DmgWindowSize {
  final num width;
  final num height;

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

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }
}

class DmgWindow {
  final DmgWindowPosition? position;
  final DmgWindowSize? size;

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

  Map<String, dynamic> toJson() {
    return {
      'position': position?.toJson(),
      'size': size?.toJson(),
    }..removeWhere((key, value) => value == null);
  }
}

class DmgCodeSign {
  final String signingIdentity;
  final String? identifier;

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

  Map<String, dynamic> toJson() {
    return {
      'signing-identity': signingIdentity,
      'identifier': identifier,
    }..removeWhere((key, value) => value == null);
  }
}

class DmgContent {
  final num x;
  final num y;
  final String type;
  final String path;
  final String? name;

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
  final String title;
  final String? icon;
  final String? background;
  final String? backgroundColor;
  final int? iconSize;
  final String? format;
  final List<DmgContent> contents;
  final DmgCodeSign? codeSign;

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
      iconSize: json['iconSize'],
      format: json['format'],
      contents: contents,
      codeSign: json['code-sign'] != null
          ? DmgCodeSign.fromJson(json['code-sign'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon,
      'background': background,
      'backgroundColor': backgroundColor,
      'iconSize': iconSize,
      'format': format,
      'contents': contents.map((e) => e.toJson()).toList(),
      'code-sign': codeSign?.toJson(),
    }..removeWhere((key, value) => value == null);
  }
}
