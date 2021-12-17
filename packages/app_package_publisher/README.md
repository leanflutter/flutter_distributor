# app_package_publisher

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/app_package_publisher.svg
[pub-url]: https://pub.dev/packages/app_package_publisher

## Quick Start

### Installation

```yaml
dependencies:
  app_package_publisher: ^0.0.3
```

## Usage

```dart
import 'dart:io';

import 'package:app_package_publisher/app_package_publisher.dart';

class AppPackagePublisherAppCenter extends AppPackagePublisher {
  @override
  Future<PublishResult> publish(File file) async {
    // ...
  }
}
```
