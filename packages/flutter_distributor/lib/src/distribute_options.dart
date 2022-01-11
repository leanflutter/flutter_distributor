import 'dart:io';

import 'release.dart';

class DistributeOptions {
  final Map<String, String>? env;
  final String output;
  final List<Release> releases;

  Directory get outputDirectory => Directory(output);

  DistributeOptions({
    this.env,
    required this.output,
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
      releases: releases,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'env': env,
      'output': output,
      'releases': releases.map((e) => e.toJson()).toList(),
    }..removeWhere((key, value) => value == null);
  }
}
