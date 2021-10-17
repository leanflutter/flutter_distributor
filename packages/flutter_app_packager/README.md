# flutter_app_packager

<!-- [![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/flutter_app_packager.svg
[pub-url]: https://pub.dev/packages/flutter_app_packager -->

Package your [Flutter](https://flutter.dev) app into OS-specific bundles (.app, .exe, etc.) via Dart or the command line.

[![Discord](https://img.shields.io/badge/discord-%237289DA.svg?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/vba8W9SF)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [flutter_app_packager](#flutter_app_packager)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
      - [⚠️ Linux requirements](#️-linux-requirements)
      - [⚠️ macOS requirements](#️-macos-requirements)
    - [Pack](#pack)
      - [Linux](#linux)
      - [macOS](#macos)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Quick Start

### Installation

```
dart pub global activate flutter_app_packager
```

#### ⚠️ Linux requirements

- `7z`

Run the following command

```
sudo apt-get install p7zip-full
```


#### ⚠️ macOS requirements

- `7z`, `appdmg`

Run the following command

```
brew install p7zip
npm install -g appdmg
```

### Pack

#### Linux

```
flutter build linux
flutter_app_packager --platform=linux
```

#### macOS

```
flutter build macos
flutter_app_packager --platform=macos
```

## License

```text
MIT License
Copyright (c) 2021 LiJianying <lijy91@foxmail.com>
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```