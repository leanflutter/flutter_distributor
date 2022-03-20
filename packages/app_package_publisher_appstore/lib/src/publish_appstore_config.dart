import 'package:app_package_publisher/app_package_publisher.dart';

const kEnvAppStoreToken = 'FIREBASE_TOKEN';
// const kEnvAppStoreToken = 'FIREBASE_TOKEN';
// const kEnvAppStoreToken = 'FIREBASE_TOKEN';
// const kEnvAppStoreToken = 'FIREBASE_TOKEN';

class PublishAppStoreConfig extends PublishConfig {
  final String? username;
  final String? password;
  final String? apiKey;
  final String? apiIssuer;

  PublishAppStoreConfig({
    this.username,
    this.password,
    this.apiKey,
    this.apiIssuer,
  });

  factory PublishAppStoreConfig.parse(Map<String, String>? environment,
      Map<String, dynamic>? publishArguments) {
    // Get token
    // String? token = (environment ?? Platform.environment)[kEnvAppStoreToken];
    // if ((token ?? '').isEmpty) {
    //   throw PublishError(
    //       'Missing `$kEnvAppStoreToken` environment variable. See:https://appstore.google.com/docs/cli?authuser=0#cli-ci-systems');
    // }
    // // Get app
    // String? app = publishArguments?['app'];
    // if ((app ?? '').isEmpty) {
    //   throw PublishError(
    //       'Missing app args. See:https://console.appstore.google.com/project/_/settings/general/?authuser=0');
    // }
    return PublishAppStoreConfig(
      username: publishArguments?['username'],
      password: publishArguments?['password'],
      apiKey: publishArguments?['apiKey'],
      apiIssuer: publishArguments?['apiIssuer'],
    );
  }

  List<String> toAppStoreCliDistributeArgs() {
    Map<String, String?> cmdData = {
      '--username': username,
      '--password': password,
      '--apiKey': apiKey,
      '--apiIssuer': apiIssuer,
    };
    // clean null value cmd
    cmdData.removeWhere((key, value) => value?.isEmpty ?? true);
    // format cmd
    List<String> cmdList = [];
    cmdData.forEach((key, value) {
      cmdList.addAll([key, value!]);
    });
    return cmdList;
  }
}
