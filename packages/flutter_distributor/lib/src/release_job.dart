class ReleaseJobPackage {
  final String platform;
  final String target;
  final Map<String, dynamic>? buildArgs;

  ReleaseJobPackage({
    required this.platform,
    required this.target,
    this.buildArgs,
  });

  factory ReleaseJobPackage.fromJson(Map<String, dynamic> json) {
    return ReleaseJobPackage(
      platform: json['platform'],
      target: json['target'],
      buildArgs: json['build_args'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'target': target,
      'build_args': buildArgs,
    }..removeWhere((key, value) => value == null);
  }
}

class ReleaseJob {
  final String name;
  final ReleaseJobPackage package;
  final String? publishTo;

  ReleaseJob({
    required this.name,
    required this.package,
    this.publishTo,
  });

  factory ReleaseJob.fromJson(Map<String, dynamic> json) {
    return ReleaseJob(
      name: json['name'],
      package: ReleaseJobPackage.fromJson(json['package']),
      publishTo: json['publish_to'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'package': package.toJson(),
      'publish_to': publishTo,
    }..removeWhere((key, value) => value == null);
  }
}
