import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:shell_executor/shell_executor.dart';

typedef PublishProgressCallback = void Function(int sent, int total);

abstract class AppPackagePublisher {
  List<Command> get requirements => [];

  String get name => throw UnimplementedError();
  List<String> get supportedPlatforms => throw UnimplementedError();

  Future<PublishResult> publish(
    File file, {
    Map<String, String>? environment,
    Map<String, dynamic>? publishArguments,
    PublishProgressCallback? onPublishProgress,
  });
}

class PublishConfig {
  Pubspec? _pubspec;

  Pubspec get pubspec {
    if (_pubspec == null) {
      final yamlString = File('pubspec.yaml').readAsStringSync();
      _pubspec = Pubspec.parse(yamlString);
    }
    return _pubspec!;
  }
}

class PublishResult {
  PublishResult({
    this.url,
  });

  final String? url;
}

class PublishError extends Error {
  PublishError([this.message]);
  final String? message;

  @override
  String toString() {
    var message = this.message;
    return (message != null) ? 'PublishError: $message' : 'PublishError';
  }
}
