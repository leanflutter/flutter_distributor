import 'dart:io';

import 'release.dart';

class DistributeOptions {
  final Map<String, String>? env;
  final String output;
  final String? artifactName;
  final List<Release> releases;

  Directory get outputDirectory => Directory(output);

  DistributeOptions({
    this.env,
    required this.output,
    this.artifactName,
    required this.releases,
  });

  factory DistributeOptions.fromJson(Map<String, dynamic> json) {
    Map<String, String> env = {};
    if (json.containsKey('env') && json['env'] != null) {
      env = Map<String, String>.from(json['env']);
    }
    List<Release> releases = ((json['releases'] ?? []) as List)
        .map((item) => Release.fromJson(item))
        .toList();
    return DistributeOptions(
      env: env,
      output: json['output'],
      artifactName: json['artifact_name'],
      releases: releases,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'env': env,
      'output': output,
      'artifact_name': artifactName,
      'releases': releases.map((e) => e.toJson()).toList(),
    }..removeWhere((key, value) => value == null);
  }
}
