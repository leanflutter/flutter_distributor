import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

const kEnvAppStoreUsername = 'APPSTORE_USERNAME';
const kEnvAppStorePassword = 'APPSTORE_PASSWORD';
const kEnvAppStoreApiKey = 'APPSTORE_APIKEY';
const kEnvAppStoreApiIssuer = 'APPSTORE_APIISSUER';

class PublishAppStoreConfig extends PublishConfig {
  PublishAppStoreConfig({
    this.username,
    this.password,
    this.apiKey,
    this.apiIssuer,
  });

  factory PublishAppStoreConfig.parse(
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
  ) {
    // Get authorization info
    String? username =
        (environment ?? Platform.environment)[kEnvAppStoreUsername];
    String? password =
        (environment ?? Platform.environment)[kEnvAppStorePassword];
    String? apiKey = (environment ?? Platform.environment)[kEnvAppStoreApiKey];
    String? apiIssuer =
        (environment ?? Platform.environment)[kEnvAppStoreApiIssuer];
    // Check username & password & apiKey & apiIssuer
    if ('$username$password$apiKey$apiIssuer'.replaceAll('null', '').isEmpty) {
      throw PublishError(
        'Missing `$kEnvAppStoreUsername` & `$kEnvAppStorePassword` | `$kEnvAppStoreApiKey` & `$kEnvAppStoreApiIssuer` environment variable. See:https://help.apple.com/asc/appsaltool/#/apdATD1E53-D1E1A1303-D1E53A1126',
      );
    }
    // Check username & password
    if (((username ?? '').isNotEmpty && (password ?? '').isEmpty) ||
        ((username ?? '').isEmpty && (password ?? '').isNotEmpty)) {
      throw PublishError(
        'Missing `$kEnvAppStoreUsername` & `$kEnvAppStorePassword` environment variable. See:https://help.apple.com/asc/appsaltool/#/apdATD1E53-D1E1A1303-D1E53A1126',
      );
    } else {
      // Check apiKey & apiIssuer
      if (((apiKey ?? '').isNotEmpty && (apiIssuer ?? '').isEmpty) ||
          ((apiKey ?? '').isEmpty && (apiIssuer ?? '').isNotEmpty)) {
        throw PublishError(
          'Missing `$kEnvAppStoreApiKey` & `$kEnvAppStoreApiIssuer` environment variable. See:https://help.apple.com/asc/appsaltool/#/apdATD1E53-D1E1A1303-D1E53A1126',
        );
      }
    }

    return PublishAppStoreConfig(
      username: username,
      password: password,
      apiKey: apiKey,
      apiIssuer: apiIssuer,
    );
  }

  final String? username;
  final String? password;
  final String? apiKey;
  final String? apiIssuer;

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
