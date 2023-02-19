class MakeError extends Error {
  final String? message;

  MakeError([this.message]);

  String toString() {
    var message = this.message;
    return (message != null) ? "MakeError: $message" : "MakeError";
  }
}
