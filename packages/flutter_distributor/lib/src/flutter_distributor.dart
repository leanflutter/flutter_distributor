import 'dart:convert';
import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';
import 'package:app_package_publisher/app_package_publisher.dart';
import 'package:flutter_app_builder/flutter_app_builder.dart';
import 'package:flutter_app_packager/flutter_app_packager.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:flutter_app_publisher/flutter_app_publisher.dart';
import 'package:yaml/yaml.dart';

import 'utils/logger.dart';
import 'distribute_options.dart';

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

  DistributeOptions? _distributeOptions;
  DistributeOptions get distributeOptions {
    if (_distributeOptions == null) {
      final yamlString = File('distribute_options.yaml').readAsStringSync();
      final yamlDoc = loadYaml(yamlString);
      _distributeOptions =
          DistributeOptions.fromJson(json.decode(json.encode(yamlDoc)));
    }
    return _distributeOptions!;
  }

  Future<void> package(
    String platform,
    List<String> targets,
    Map<String, dynamic> buildArguments,
  ) async {
    Directory outputDirectory =
        _distributeOptions?.outputDirectory ?? Directory('dist/');

    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }

    bool isBuildOnlyOnce = platform != 'android';
    BuildResult? buildResult;

    for (String target in targets) {
      if (!isBuildOnlyOnce || (isBuildOnlyOnce && buildResult == null)) {
        logger.info('Building ${pubspec.name}-$platform');
        buildResult = await _builder.build(platform, target, buildArguments);
      }

      if (buildResult != null) {
        MakeResult makeResult = await _packager.package(
          buildResult.outputDirectory,
          outputDirectory: outputDirectory,
          platform: platform,
          flavor: buildArguments['flavor'],
          target: target,
        );

        logger.info('Successfully packaged ${makeResult.outputFile.path}');
      }
    }

    return Future.value();
  }

  Future<void> publish(
    File file,
    List<String> targets,
  ) async {
    for (String target in targets) {
      PublishResult publishResult = await _publisher.publish(
        file,
        target: target,
        onProgressUpdate: (progress) {
          print('Publish to $target: ${(progress * 100).toInt()}%');
        },
      );
      print('Published: ${publishResult.url}');
    }
    return Future.value();
  }

  Future<void> release(
    String type,
  ) async {
    return Future.value();
  }
}
