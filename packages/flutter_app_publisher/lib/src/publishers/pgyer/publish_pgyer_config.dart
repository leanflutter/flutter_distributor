import 'package:flutter_app_publisher/src/api/app_package_publisher.dart';

class PublishPgyerConfig extends PublishConfig {
  PublishPgyerConfig({
    required this.apiKey,
  });

  final String apiKey;
}
