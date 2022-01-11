import 'dart:convert';
import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:colorize/colorize.dart';
import 'package:flutter_app_builder/flutter_app_builder.dart';
import 'package:flutter_app_packager/flutter_app_packager.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:flutter_app_publisher/flutter_app_publisher.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'utils/logger.dart';
import 'utils/progress_bar.dart';
import 'utils/pub_dev_api.dart';
import 'distribute_options.dart';
import 'release.dart';
import 'release_job.dart';

class FlutterDistributor {
  final FlutterAppBuilder _builder = FlutterAppBuilder();
  final FlutterAppPackager _packager = FlutterAppPackager();
  final FlutterAppPublisher _publisher = FlutterAppPublisher();

  Pubspec? _pubspec;
  Pubspec get pubspec {
    if (_pubspec == null) {
      final yamlString = File('pubspec.yaml').readAsStringSync();
      _pubspec = Pubspec.parse(yamlString);
    }
    return _pubspec!;
  }

  Map<String, String> _environment = {};
  Map<String, String> get environment {
    if (_environment.keys.isEmpty) {
      for (String key in Platform.environment.keys) {
        String? value = Platform.environment[key];
        if ((value ?? '').isNotEmpty) {
          _environment[key] = value!;
        }
      }
      List<String> keys = distributeOptions.env?.keys.toList() ?? [];
      for (String key in keys) {
        String? value = distributeOptions.env?[key];

        if ((value ?? '').isNotEmpty) {
          _environment[key] = value!;
        }
      }
    }
    return _environment;
  }

  DistributeOptions? _distributeOptions;
  DistributeOptions get distributeOptions {
    if (_distributeOptions == null) {
      File file = File('distribute_options.yaml');
      if (file.existsSync()) {
        final yamlString = File('distribute_options.yaml').readAsStringSync();
        final yamlDoc = loadYaml(yamlString);
        _distributeOptions = DistributeOptions.fromJson(
          json.decode(json.encode(yamlDoc)),
        );
      } else {
        _distributeOptions = DistributeOptions(
          output: 'dist/',
          releases: [],
        );
      }
    }
    return _distributeOptions!;
  }

  Future<String?> _getCurrentVersion() async {
    try {
      var scriptFile = Platform.script.toFilePath();
      var pathToPubSpecYaml = p.join(p.dirname(scriptFile), '../pubspec.yaml');
      var pathToPubSpecLock = p.join(p.dirname(scriptFile), '../pubspec.lock');

      var pubSpecYamlFile = File(pathToPubSpecYaml);

      var pubSpecLockFile = File(pathToPubSpecLock);

      if (pubSpecLockFile.existsSync()) {
        var yamlDoc = loadYaml(await pubSpecLockFile.readAsString());
        if (yamlDoc['packages']['flutter_distributor'] == null) {
          var yamlDoc = loadYaml(await pubSpecYamlFile.readAsString());
          return yamlDoc['version'];
        }

        return yamlDoc['packages']['flutter_distributor']['version'];
      }
    } on Exception catch (_) {
      return null;
    }
  }

  Future<void> checkVersion() async {
    String? currentVersion = await _getCurrentVersion();
    String? latestVersion =
        await PubDevApi.getLatestVersionFromPackage('flutter_distributor');

    if (currentVersion != null &&
        latestVersion != null &&
        currentVersion.compareTo(latestVersion) < 0) {
      Colorize msg = Colorize([
        '╔════════════════════════════════════════════════════════════════════════════╗',
        '║ A new version of Flutter Distributor is available!                         ║',
        '║                                                                            ║',
        '║ To update to the latest version, run "flutter_distributor upgrade".        ║',
        '╚════════════════════════════════════════════════════════════════════════════╝',
        '',
      ].join('\n'));
      print(msg.yellow());
    }
    return Future.value();
  }

  Future<String?> getCurrentVersion() async {
    return await _getCurrentVersion();
  }

  Future<List<MakeResult>> package(
    String platform,
    List<String> targets, {
    required bool cleanOnceBeforeBuild,
    required Map<String, dynamic> buildArguments,
  }) async {
    List<MakeResult> makeResultList = [];

    try {
      Directory outputDirectory = distributeOptions.outputDirectory;
      if (!outputDirectory.existsSync()) {
        outputDirectory.createSync(recursive: true);
      }

      bool isBuildOnlyOnce = platform != 'android';
      BuildResult? buildResult;

      for (String target in targets) {
        logger.info('Packaging ${pubspec.name} ${pubspec.version} as $target:');
        if (!isBuildOnlyOnce || (isBuildOnlyOnce && buildResult == null)) {
          logger.info('Building...');
          buildResult = await _builder.build(
            platform,
            target,
            cleanOnceBeforeBuild: cleanOnceBeforeBuild,
            buildArguments: buildArguments,
            onProcessStdOut: (data) {
              String message = utf8.decoder.convert(data).trim();
              logger.info(Colorize(message).darkGray());
            },
            onProcessStdErr: (data) {
              String message = utf8.decoder.convert(data).trim();
              logger.info(Colorize(message).darkGray());
            },
          );
          logger.info(
            Colorize('Successfully builded ${buildResult.outputDirectory}')
                .green(),
          );
        }

        if (buildResult != null) {
          MakeResult makeResult = await _packager.package(
            buildResult.outputDirectory,
            outputDirectory: outputDirectory,
            platform: platform,
            flavor: buildArguments['flavor'],
            target: target,
            onProcessStdOut: (data) {
              String message = utf8.decoder.convert(data).trim();
              logger.info(Colorize(message).darkGray());
            },
            onProcessStdErr: (data) {
              String message = utf8.decoder.convert(data).trim();
              logger.info(Colorize(message).darkGray());
            },
          );

          logger.info(
            Colorize('Successfully packaged ${makeResult.outputFile.path}')
                .green(),
          );

          makeResultList.add(makeResult);
        }
      }
    } on Error catch (error) {
      logger.shout(Colorize(error.toString()).red());
      logger.shout(Colorize(error.stackTrace.toString()).red());
    }

    return makeResultList;
  }

  Future<List<PublishResult>> publish(
    File file,
    List<String> targets,
  ) async {
    List<PublishResult> publishResultList = [];
    try {
      for (String target in targets) {
        ProgressBar progressBar = ProgressBar(
          format: 'Publishing to $target: {bar} {value}/{total} {percentage}%',
        );
        PublishResult publishResult = await _publisher.publish(
          file,
          target: target,
          environment: this.environment,
          onPublishProgress: (sent, total) {
            if (!progressBar.isActive) {
              progressBar.start(total, sent);
            } else {
              progressBar.update(sent);
            }
          },
        );
        if (progressBar.isActive) progressBar.stop();
        logger.info(
          Colorize('Successfully published ${publishResult.url}').green(),
        );

        publishResultList.add(publishResult);
      }
    } on Error catch (error) {
      logger.shout(Colorize(error.toString()).red());
      logger.shout(Colorize(error.stackTrace.toString()).red());
    }
    return publishResultList;
  }

  Future<void> release(
    String name, {
    required bool cleanOnceBeforeBuild,
  }) async {
    Directory outputDirectory = distributeOptions.outputDirectory;
    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }

    List<Release> releases = [];

    if (name.isNotEmpty) {
      releases =
          distributeOptions.releases.where((e) => e.name == name).toList();
    }

    if (releases.isEmpty) {
      throw Exception('Missing/incomplete `distribute_options.yaml` file.');
    }

    for (Release release in releases) {
      for (ReleaseJob job in release.jobs) {
        List<MakeResult> makeResultList = await package(
          job.package.platform,
          [job.package.target],
          cleanOnceBeforeBuild: cleanOnceBeforeBuild,
          buildArguments: job.package.buildArgs ?? {},
        );

        if (job.publishTo != null) {
          MakeResult makeResult = makeResultList.first;
          await publish(
            makeResult.outputFile,
            [job.publishTo!],
          );
        }
      }
    }
    return Future.value();
  }

  Future<void> upgrade() async {
    Process process = await Process.start(
      'dart',
      ['pub', 'global', 'activate', 'flutter_distributor'],
    );
    process.stdout.listen((event) {
      String msg = utf8.decoder.convert(event).trim();
      logger.info(msg);
    });
    process.stderr.listen((event) {
      String msg = utf8.decoder.convert(event).trim();
      logger.shout(msg);
    });

    return Future.value();
  }
}
