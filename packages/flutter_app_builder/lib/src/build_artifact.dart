class BuildArtifact {
  final String type;
  final String path;

  BuildArtifact({
    required this.type,
    required this.path,
  });

  factory BuildArtifact.file(String path) {
    return BuildArtifact(type: 'file', path: path);
  }

  factory BuildArtifact.directory(String path) {
    return BuildArtifact(type: 'directory', path: path);
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'path': path,
    }..removeWhere((key, value) => value == null);
  }
}
