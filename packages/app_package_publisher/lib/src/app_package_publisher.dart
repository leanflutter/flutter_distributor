import 'dart:io';

typedef ProgressUpdateCallback = void Function(double progress);

abstract class AppPackagePublisher {
  String get name => throw UnimplementedError();
  List<String> get supportedPlatforms => throw UnimplementedError();

  Future<PublishResult> publish(
    File file, {
    ProgressUpdateCallback? onProgressUpdate,
  });
}

class PublishConfig {}

class PublishResult {
  final String? url;

  PublishResult({
    this.url,
  });
}

class PublishError extends Error {
  final String? message;

  PublishError([this.message]);

  String toString() {
    var message = this.message;
    return (message != null) ? "PublishError: $message" : "PublishError";
  }
}
