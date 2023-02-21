import 'package:app_package_publisher/app_package_publisher.dart';

class PublishFirConfig extends PublishConfig {
  PublishFirConfig({
    required this.apiToken,
  });

  final String apiToken;
}
