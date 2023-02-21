import 'dart:io';

import 'package:app_package_maker/src/make_config.dart';
import 'package:app_package_maker/src/make_error.dart';

class MakeResult {
  MakeResult(
    this.config, {
    this.duration,
  });

  final MakeConfig config;
  final Duration? duration;

  File get outputFile => config.outputFile;

  Map<String, dynamic> toJson() {
    return {
      'config': config.toJson(),
      'outputFile': {
        'path': outputFile.path,
      },
      'duration': duration,
    }..removeWhere((key, value) => value == null);
  }
}

abstract class MakeResultResolver {
  MakeResult resolve(MakeConfig config);
}

class DefaultMakeResultResolver extends MakeResultResolver {
  @override
  MakeResult resolve(MakeConfig config) {
    MakeResult makeResult = MakeResult(config);
    if (!makeResult.outputFile.existsSync()) {
      throw MakeError('No output file found.');
    }
    return makeResult;
  }
}
