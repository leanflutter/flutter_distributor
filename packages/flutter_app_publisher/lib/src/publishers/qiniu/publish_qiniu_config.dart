import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

const kEnvQiniuAccessKey = 'QINIU_ACCESS_KEY';
const kEnvQiniuSecretKey = 'QINIU_SECRET_KEY';

class PublishQiniuConfig extends PublishConfig {
  PublishQiniuConfig({
    required this.accessKey,
    required this.secretKey,
    required this.bucket,
    this.bucketDomain,
    this.savekeyPrefix,
  });

  factory PublishQiniuConfig.parse(
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
  ) {
    String? accessKey =
        (environment ?? Platform.environment)[kEnvQiniuAccessKey];
    String? secretKey =
        (environment ?? Platform.environment)[kEnvQiniuSecretKey];
    if ((accessKey ?? '').isEmpty) {
      throw PublishError('Missing `$kEnvQiniuAccessKey` environment variable.');
    }
    if ((secretKey ?? '').isEmpty) {
      throw PublishError('Missing `$kEnvQiniuSecretKey` environment variable.');
    }
    return PublishQiniuConfig(
      accessKey: accessKey!,
      secretKey: secretKey!,
      bucket: publishArguments?['bucket'],
      bucketDomain: publishArguments?['bucket-domain'],
      savekeyPrefix: publishArguments?['savekey-prefix'] ?? '',
    );
  }

  final String accessKey;
  final String secretKey;
  final String bucket;
  String? bucketDomain;
  String? savekeyPrefix;
}
