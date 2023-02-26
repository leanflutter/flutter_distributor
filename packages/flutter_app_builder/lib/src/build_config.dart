enum BuildMode { profile, release }

class BuildConfig {
  BuildConfig({
    this.arguments = const {},
  });

  final Map<String, dynamic> arguments;

  BuildMode get mode {
    return arguments.containsKey('profile')
        ? BuildMode.profile
        : BuildMode.release;
  }

  String? get flavor {
    return arguments['flavor'];
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'flavor': flavor,
      'arguments': arguments,
    }..removeWhere((key, value) => value == null);
  }
}
