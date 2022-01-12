import 'package:app_package_publisher/app_package_publisher.dart';

class PublishFirebaseConfig extends PublishConfig {
  final String appId;
  final String? token;

  PublishFirebaseConfig({
    required this.appId,
    this.token,
  });
}
