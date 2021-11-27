import 'dart:io';

import 'app_builder.dart';

class AppBuilderIos extends AppBuilder {
  @override
  String get platform => 'ios';

  @override
  Directory getOutputDirectory({
    String? flavor,
    String? target,
  }) =>
      throw UnimplementedError();
}
