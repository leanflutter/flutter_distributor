enum BuildMode { profile, release }

class BuildConfig {
  BuildConfig({
    this.mode = BuildMode.release,
    this.flavor,
    this.arguments = const {},
  });

  final BuildMode mode;
  final String? flavor;
  final Map<String, dynamic> arguments;

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'flavor': flavor,
      'arguments': arguments,
    }..removeWhere((key, value) => value == null);
  }
}
