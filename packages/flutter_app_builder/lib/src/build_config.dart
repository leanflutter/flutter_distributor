enum BuildMode { profile, release }

class BuildConfig {
  final BuildMode mode;
  final String? flavor;
  final Map<String, dynamic> arguments;

  BuildConfig({
    this.mode = BuildMode.release,
    this.flavor,
    this.arguments = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'flavor': flavor,
      'arguments': arguments,
    }..removeWhere((key, value) => value == null);
  }
}
