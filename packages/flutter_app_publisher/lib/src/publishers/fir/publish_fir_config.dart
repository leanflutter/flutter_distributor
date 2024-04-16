import 'package:flutter_app_publisher/src/api/app_package_publisher.dart';

class PublishFirConfig extends PublishConfig {
  PublishFirConfig({
    required this.apiToken,
  });

  final String apiToken;
}
