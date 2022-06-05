import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:app_package_maker/app_package_maker.dart';

class MakeExeConfig extends MakeConfig {
  String? scriptTemplate;
  final String appId;
  String? executableName;
  String? displayName;
  String? publisherName;
  String? publisherUrl;
  bool? createDesktopIcon;
  bool? launchAtStartup;
  String? installDirName;
  List<String>? locales;

  String get defaultExecutableName {
    File executableFile = packagingDirectory
        .listSync()
        .where((e) => e.path.endsWith('.exe'))
        .map((e) => File(e.path))
        .first;
    return p.basename(executableFile.path);
  }

  String get defaultInstallDirName => appName;

  String get sourceDir => p.basename(packagingDirectory.path);
  String get outputBaseFileName =>
      p.basename(outputFile.path).replaceAll('.exe', '');

  MakeExeConfig({
    this.scriptTemplate,
    required this.appId,
    this.executableName,
    this.displayName,
    this.publisherName,
    this.publisherUrl,
    this.createDesktopIcon,
    this.launchAtStartup,
    this.installDirName,
    this.locales,
  });

  factory MakeExeConfig.fromJson(Map<String, dynamic> json) {
    List<String>? locales =
        json['locales'] != null ? List<String>.from(json['locales']) : null;
    if (locales == null || locales.isEmpty) locales = ['en'];

    MakeExeConfig makeExeConfig = MakeExeConfig(
      scriptTemplate: json['script_template'],
      appId: json['app_id'] ?? json['appId'],
      executableName: json['executable_name'],
      displayName: json['display_name'],
      publisherName: json['publisher_name'] ?? json['appPublisher'],
      publisherUrl: json['publisher_url'] ?? json['appPublisherUrl'],
      createDesktopIcon: json['create_desktop_icon'],
      launchAtStartup: json['launch_at_startup'],
      installDirName: json['install_dir_name'],
      locales: locales,
    );
    return makeExeConfig;
  }

  Map<String, dynamic> toJson() {
    return {
      'script_template': scriptTemplate,
      'app_id': appId,
      'app_name': appName,
      'app_version': appVersion.toString(),
      'executable_name': executableName,
      'display_name': displayName,
      'publisher_name': publisherName,
      'publisher_url': publisherUrl,
      'create_desktop_icon': createDesktopIcon,
      'launch_at_startup': launchAtStartup,
      'install_dir_name': installDirName,
      'locales': locales,
    }..removeWhere((key, value) => value == null);
  }
}
