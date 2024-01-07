import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:shell_executor/shell_executor.dart';

class FlutterVersion {
  const FlutterVersion({
    this.frameworkVersion,
    this.channel,
    this.repositoryUrl,
    this.frameworkRevision,
    this.frameworkCommitDate,
    this.engineRevision,
    this.dartSdkVersion,
    this.devToolsVersion,
    this.flutterVersion,
  });

  factory FlutterVersion.fromJson(Map<String, dynamic> json) {
    return FlutterVersion(
      frameworkVersion: json['frameworkVersion'] as String?,
      channel: json['channel'] as String?,
      repositoryUrl: json['repositoryUrl'] as String?,
      frameworkRevision: json['frameworkRevision'] as String?,
      frameworkCommitDate: json['frameworkCommitDate'] as String,
      engineRevision: json['engineRevision'] as String?,
      dartSdkVersion: json['dartSdkVersion'] as String?,
      devToolsVersion: json['devToolsVersion'] as String?,
      flutterVersion: json['flutterVersion'] as String? ??
          (json['frameworkVersion'] as String?),
    );
  }

  final String? frameworkVersion;
  final String? channel;
  final String? repositoryUrl;
  final String? frameworkRevision;
  final String? frameworkCommitDate;
  final String? engineRevision;
  final String? dartSdkVersion;
  final String? devToolsVersion;
  final String? flutterVersion;

  bool isGreaterOrEqual(String versionString) {
    // just keep the first part of the version string
    final String currentVersionString = flutterVersion!.split('-').first;
    final Version currentVersion = Version.parse(currentVersionString);
    return currentVersion.compareTo(Version.parse(versionString)) >= 0;
  }
}

class _Flutter extends Command {
  @override
  String get executable {
    String flutterRoot = environment?['FLUTTER_ROOT'] ?? '';
    if (flutterRoot.isNotEmpty) {
      flutterRoot = pathExpansion(flutterRoot, environment ?? {});
      if (!Directory(flutterRoot).existsSync()) {
        throw CommandError(
          this,
          'FLUTTER_ROOT environment variable is set to a path that does not exist: $flutterRoot',
        );
      }
      return p.join(flutterRoot, 'bin', 'flutter');
    }
    return 'flutter';
  }

  Map<String, String>? environment;

  _Flutter withEnv(Map<String, String>? environment) {
    this.environment = environment;
    return this;
  }

  FlutterVersion get version {
    final result = execSync(
      ['--version', '--machine'],
      environment: environment,
      runInShell: true,
    );
    final String jsonString = '${result.stdout}';
    return FlutterVersion.fromJson(
      Map<String, dynamic>.from(
        json.decode(jsonString) as Map,
      ),
    );
  }

  Future<void> clean() {
    return exec(
      ['clean'],
      environment: environment,
    );
  }

  Future<ProcessResult> build(List<String> arguments) {
    return exec(
      ['build', ...arguments],
      environment: environment,
    );
  }

  @override
  Future<void> install() {
    throw UnimplementedError();
  }
}

final flutter = _Flutter();
