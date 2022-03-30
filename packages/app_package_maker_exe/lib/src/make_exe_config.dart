import 'package:app_package_maker/app_package_maker.dart';

class MakeExeConfig extends MakeConfig {
  final String appId;
  String? appPublisher;
  String? appPublisherUrl;
  String? appDisplayName;
  String? appExeFileName;
  String? innoSetupDir;
  bool defaultDesktopIconCkecked;

  MakeExeConfig({
    required this.appId,
    this.appPublisher,
    this.appPublisherUrl,
    this.appDisplayName,
    this.appExeFileName,
    this.innoSetupDir,
    this.defaultDesktopIconCkecked=false,
  });


  factory MakeExeConfig.fromJson(Map<String, dynamic> json) {
    return MakeExeConfig(
      appId: json['appId'],
      appPublisher: json['appPublisher'],
      appPublisherUrl: json['appPublisherUrl'],
      appDisplayName: json['appDisplayName'],
      appExeFileName: json['appExeFileName'],
      innoSetupDir: json['innoSetupDir'],
      defaultDesktopIconCkecked: json['defaultDesktopIconCkecked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'appPublisher': appPublisher,
      'appPublisherUrl': appPublisherUrl,
      'appDisplayName': appDisplayName,
      'appExeFileName': appExeFileName,
      'innoSetupDir': innoSetupDir,
      'defaultDesktopIconCkecked': defaultDesktopIconCkecked,
    }..removeWhere((key, value) => value == null);
  }
}
