import 'package:flutter_distributor/src/release_job.dart';

class Release {
  Release({
    required this.name,
    required this.jobs,
  });

  factory Release.fromJson(Map<String, dynamic> json) {
    List<ReleaseJob> jobs = (json['jobs'] as List)
        .map((item) => ReleaseJob.fromJson(item))
        .toList();
    return Release(
      name: json['name'],
      jobs: jobs,
    );
  }

  final String name;
  final List<ReleaseJob> jobs;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'jobs': jobs.map((e) => e.toJson()).toList(),
    }..removeWhere((key, value) => value == null);
  }
}
