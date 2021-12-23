import 'dart:io';

class DistributeRelease {
  final String name;
  final String type;
  final String platform;
  final String target;

  DistributeRelease({
    required this.name,
    required this.type,
    required this.platform,
    required this.target,
  });

  factory DistributeRelease.fromJson(Map<String, dynamic> json) {
    return DistributeRelease(
      name: json['name'],
      type: json['type'],
      platform: json['platform'],
      target: json['target'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'target': target,
    }..removeWhere((key, value) => value == null);
  }
}

class DistributeOptions {
  final String output;
  final List<DistributeRelease> releases;

  Directory get outputDirectory => Directory(output);

  DistributeOptions({
    required this.output,
    required this.releases,
  });

  factory DistributeOptions.fromJson(Map<String, dynamic> json) {
    List<DistributeRelease> releases = (json['releases'] as List)
        .map((item) => DistributeRelease.fromJson(item))
        .toList();

    return DistributeOptions(
      output: json['output'],
      releases: releases,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'output': output,
      'releases': releases.map((e) => e.toJson()).toList(),
    }..removeWhere((key, value) => value == null);
  }
}
