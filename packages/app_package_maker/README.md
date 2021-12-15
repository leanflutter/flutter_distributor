# app_package_maker

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/app_package_maker.svg
[pub-url]: https://pub.dev/packages/app_package_maker

## Quick Start

### Installation

```yaml
dependencies:
  app_package_maker: ^0.0.3
```

## Usage

```dart
import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class AppPackageMakerZip extends AppPackageMaker {
  String get name => 'zip';

  @override
  Future<MakeResult> make(
    Directory appDirectory, {
    required Directory outputDirectory,
    String? platform,
  }) async {
    // ...
  }
}
```

## License

[MIT](./LICENSE)