# app_package_parser

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/app_package_parser.svg
[pub-url]: https://pub.dev/packages/app_package_parser

## Quick Start

### Installation

```yaml
dependencies:
  app_package_parser: ^0.0.3
```

## Usage

```dart
import 'dart:io';

import 'package:app_package_parser/app_package_parser.dart';

class AppPackageParserApk extends AppPackageParser {
  String get name => 'apk';

  @override
  Future<AppPackageInfo> parse(File file) {
    // ...
  }
}
```

## License

[MIT](./LICENSE)