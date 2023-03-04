import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:flutter_app_publisher/src/publishers/qiniu/publish_qiniu_config.dart';
// import 'package:parse_app_package/parse_app_package.dart';
import 'package:qiniu_sdk_base/qiniu_sdk_base.dart';

class AppPackagePublisherQiniu extends AppPackagePublisher {
  @override
  String get name => 'qiniu';

  @override
  List<String> get supportedPlatforms => [
        'android',
        'ios',
        'linux',
        'macos',
        'windows',
      ];

  @override
  Future<PublishResult> publish(
    File file, {
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  }) async {
    PublishQiniuConfig publishConfig = PublishQiniuConfig.parse(
      environment,
      publishArguments,
    );

    try {
      Auth auth = Auth(
        accessKey: publishConfig.accessKey,
        secretKey: publishConfig.secretKey,
      );

      String saveKey =
          '${publishConfig.savekeyPrefix}${file.path.split('/').last}';

      String uploadToken = auth.generateUploadToken(
        putPolicy: PutPolicy(
          scope: publishConfig.bucket,
          deadline: (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,
          saveKey: saveKey,
        ),
      );

      Storage storage = Storage();
      PutController putController = PutController();

      int sent = 0;
      int total = file.lengthSync();

      putController.addSendProgressListener((double percent) {
        if (onPublishProgress != null) {
          sent = (total * percent).toInt();
          onPublishProgress(sent, total);
        }
      });

      if (onPublishProgress != null) {
        onPublishProgress(sent, total);
      }
      PutResponse putResponse = await storage.putFile(
        file,
        uploadToken,
        options: PutOptions(
          controller: putController,
        ),
      );
      return PublishResult(
        url:
            '${publishConfig.bucketDomain ?? '<bucketDomain>'}/${putResponse.key}',
      );
    } on StorageError catch (error) {
      throw PublishError('${error.code} - ${error.message}');
    } catch (error) {
      rethrow;
    }
  }
}
