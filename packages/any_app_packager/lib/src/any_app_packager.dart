import 'dart:convert';
import 'dart:io';

import 'package:any_app_packager/src/utils/logger.dart';
import 'package:flutter_app_builder/flutter_app_builder.dart';
import 'package:flutter_app_packager/flutter_app_packager.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

class AnyAppPackager {
  final FlutterAppBuilder _appBuilder = FlutterAppBuilder();
  final FlutterAppPackager _appPackager = FlutterAppPackager();

  final Map<String, String> _globalVariables = {};
  Map<String, String> get globalVariables {
    if (_globalVariables.keys.isEmpty) {
      for (String key in Platform.environment.keys) {
        String? value = Platform.environment[key];
        if ((value ?? '').isNotEmpty) {
          _globalVariables[key] = value!;
        }
      }
    }
    return _globalVariables;
  }

  /// Packages the app for the given platform and target.
  Future<List<MakeResult>> package(
    String platform,
    List<String> targets, {
    String? channel,
    String? artifactName,
    required bool cleanBeforeBuild,
    required Map<String, dynamic> buildArguments,
    Map<String, String>? variables,
  }) async {
    List<MakeResult> makeResultList = [];

    try {
      Directory outputDirectory = Directory('dist/');
      if (!outputDirectory.existsSync()) {
        outputDirectory.createSync(recursive: true);
      }

      if (cleanBeforeBuild) {
        await _appBuilder.clean();
      }

      bool isBuildOnlyOnce = platform != 'android';
      BuildResult? buildResult;

      final yamlString = File('pubspec.yaml').readAsStringSync();
      Pubspec pubspec = Pubspec.parse(yamlString);

      for (String target in targets) {
        logger.info('Packaging ${pubspec.name} ${pubspec.version} as $target:');
        if (!isBuildOnlyOnce || (isBuildOnlyOnce && buildResult == null)) {
          try {
            buildResult = await _appBuilder.build(
              platform,
              target: target,
              arguments: buildArguments,
              environment: variables ?? globalVariables,
            );
            print(
              const JsonEncoder.withIndent('  ').convert(buildResult.toJson()),
            );

            logger.fine(
              'Successfully built ${buildResult.outputDirectory} in ${buildResult.duration!.inSeconds}s',
            );
          } on UnsupportedError catch (error) {
            logger.warning('Warning: ${error.message}');
            continue;
          } catch (error) {
            rethrow;
          }
        }

        if (buildResult != null) {
          String buildMode =
              buildArguments.containsKey('profile') ? 'profile' : 'release';
          Map<String, dynamic>? arguments = {
            'build_mode': buildMode,
            'flavor': buildArguments['flavor'],
            'channel': channel,
            'artifact_name': artifactName,
          };
          MakeResult makeResult = await _appPackager.package(
            platform,
            target,
            arguments,
            outputDirectory,
            buildOutputDirectory: buildResult.outputDirectory,
            buildOutputFiles: buildResult.outputFiles,
          );
          print(
            const JsonEncoder.withIndent('  ').convert(makeResult.toJson()),
          );
          FileSystemEntity artifact = makeResult.artifacts.first;
          logger.fine('Successfully packaged ${artifact.path}');
          makeResultList.add(makeResult);
        }
      }
    } catch (error) {
      logger.severe(error.toString());
      if (error is Error) {
        logger.severe(error.stackTrace.toString());
      }
      rethrow;
    }
    return makeResultList;
  }
}
