import 'release_job.dart';

class Release {
  final String name;
  final List<ReleaseJob> jobs;

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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'jobs': jobs.map((e) => e.toJson()).toList(),
    }..removeWhere((key, value) => value == null);
  }
}
