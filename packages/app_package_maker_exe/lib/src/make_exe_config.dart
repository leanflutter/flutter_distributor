import 'package:app_package_maker/app_package_maker.dart';

class MakeExeConfig extends MakeConfig {
  final String appId;
  String? appPublisher;
  String? appPublisherUrl;

  MakeExeConfig({
    required this.appId,
    this.appPublisher,
    this.appPublisherUrl,
  });

  factory MakeExeConfig.fromJson(Map<String, dynamic> json) {
    return MakeExeConfig(
      appId: json['appId'],
      appPublisher: json['appPublisher'],
      appPublisherUrl: json['appPublisherUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'appPublisher': appPublisher,
      'appPublisherUrl': appPublisherUrl,
    }..removeWhere((key, value) => value == null);
  }
}
