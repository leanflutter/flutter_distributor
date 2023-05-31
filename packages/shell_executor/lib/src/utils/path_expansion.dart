String pathExpansion(
  String path, [
  Map<String, String> environment = const {},
]) {
  if (path.startsWith('~/')) {
    final home = environment['HOME'] ?? environment['USERPROFILE'];
    path = '$home${path.substring(1)}';
  }

  final matches = [
    ...RegExp(r'\$(\w+)').allMatches(path),
    ...RegExp(r'\$\{(\w+)\}').allMatches(path)
  ];
  for (final match in matches) {
    final envName = match.group(1);
    final envValue = environment[envName];
    path = path.replaceFirst(match.group(0)!, envValue ?? '');
  }
  return path;
}
