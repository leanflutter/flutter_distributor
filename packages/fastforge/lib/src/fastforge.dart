import 'dart:convert';
import 'dart:io';

import 'package:fastforge/src/extensions/extensions.dart';
import 'package:fastforge/src/utils/utils.dart';
import 'package:flutter_app_builder/flutter_app_builder.dart';
import 'package:flutter_app_packager/flutter_app_packager.dart';
import 'package:flutter_app_publisher/flutter_app_publisher.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:shell_executor/shell_executor.dart';
import 'package:shell_uikit/shell_uikit.dart';
import 'package:yaml/yaml.dart';

class Fastforge {
  Fastforge() {
    ShellExecutor.global = DefaultShellExecutor();
  }

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

  Future<String?> _getCurrentVersion() async {
    try {
      var scriptFile = Platform.script.toFilePath();
      var pathToPubSpecYaml = p.join(p.dirname(scriptFile), '../pubspec.yaml');
      var pathToPubSpecLock = p.join(p.dirname(scriptFile), '../pubspec.lock');

      var pubSpecYamlFile = File(pathToPubSpecYaml);

      var pubSpecLockFile = File(pathToPubSpecLock);

      if (pubSpecLockFile.existsSync()) {
        var yamlDoc = loadYaml(await pubSpecLockFile.readAsString());
        if (yamlDoc['packages']['fastforge'] == null) {
          var yamlDoc = loadYaml(await pubSpecYamlFile.readAsString());
          return yamlDoc['version'];
        }

        return yamlDoc['packages']['fastforge']['version'];
      }
    } catch (_) {}
    return null;
  }

  Future<bool> checkVersion() async {
    String? currentVersion = await _getCurrentVersion();
    String? latestVersion =
        await PubDevApi.getLatestVersionFromPackage('fastforge');

    if (currentVersion != null &&
        latestVersion != null &&
        currentVersion.compareTo(latestVersion) < 0) {
      String msg = [
        '╔════════════════════════════════════════════════════════════════════════════╗',
        '║ A new version of Fastforge is available!                                 ║',
        '║                                                                            ║',
        '║ To update to the latest version, run "fastforge upgrade".                   ║',
        '╚════════════════════════════════════════════════════════════════════════════╝',
        '',
      ].join('\n');
      print(msg);
      return Future.value(true);
    }
    return Future.value(false);
  }

  Future<String?> getCurrentVersion() async {
    return await _getCurrentVersion();
  }

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
        await _builder.clean();
      }

      bool isBuildOnlyOnce = platform != 'android';
      BuildResult? buildResult;

      for (String target in targets) {
        logger.info('Packaging ${pubspec.name} ${pubspec.version} as $target:');
        if (!isBuildOnlyOnce || (isBuildOnlyOnce && buildResult == null)) {
          try {
            buildResult = await _builder.build(
              platform,
              target: target,
              arguments: buildArguments,
              environment: variables ?? globalVariables,
            );
            print(
              const JsonEncoder.withIndent('  ').convert(buildResult.toJson()),
            );
            logger.info(
              'Successfully built ${buildResult.outputDirectory} in ${buildResult.duration!.inSeconds}s'
                  .brightGreen(),
            );
          } on UnsupportedError catch (error) {
            logger.warning('Warning: ${error.message}'.yellow());
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
          MakeResult makeResult = await _packager.package(
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
          logger.info(
            'Successfully packaged ${artifact.path}'.brightGreen(),
          );
          makeResultList.add(makeResult);
        }
      }
    } catch (error) {
      logger.severe(error.toString().red());
      if (error is Error) {
        logger.severe(error.stackTrace.toString().red());
      }
      rethrow;
    }

    return makeResultList;
  }

  Future<List<PublishResult>> publish(
    FileSystemEntity fileSystemEntity,
    List<String> targets, {
    Map<String, dynamic>? publishArguments,
    Map<String, String>? variables,
  }) async {
    List<PublishResult> publishResultList = [];
    try {
      for (String target in targets) {
        ProgressBar progressBar = ProgressBar(
          format: 'Publishing to $target: {bar} {value}/{total} {percentage}%',
        );

        Map<String, dynamic>? newPublishArguments = {};

        if (publishArguments != null) {
          for (var key in publishArguments.keys) {
            if (!key.startsWith('$target-')) continue;
            dynamic value = publishArguments[key];

            if (value is List) {
              // ignore: prefer_for_elements_to_map_fromiterable
              value = Map.fromIterable(
                value,
                key: (e) => e.split('=')[0],
                value: (e) => e.split('=')[1],
              );
            }

            newPublishArguments.putIfAbsent(
              key.replaceAll('$target-', ''),
              () => value,
            );
          }
        }

        if (newPublishArguments.keys.isEmpty) {
          newPublishArguments = publishArguments;
        }

        PublishResult publishResult = await _publisher.publish(
          fileSystemEntity,
          target: target,
          environment: variables ?? globalVariables,
          publishArguments: newPublishArguments,
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
          'Successfully published ${publishResult.url}'.brightGreen(),
        );
        publishResultList.add(publishResult);
      }
    } on Error catch (error) {
      logger.severe(error.toString().brightRed());
      logger.severe(error.stackTrace.toString().brightRed());
      rethrow;
    }
    return publishResultList;
  }

  Future<void> upgrade() async {
    await $(
      'dart',
      ['pub', 'global', 'activate', 'fastforge'],
    );
    return Future.value();
  }
}
