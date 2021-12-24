# flutter_distributor

<!-- [![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/flutter_distributor.svg
[pub-url]: https://pub.dev/packages/flutter_distributor -->

Package your [Flutter](https://flutter.dev) app into OS-specific bundles (.dmg, .exe, etc.) via Dart or the command line.

[![Discord](https://img.shields.io/badge/discord-%237289DA.svg?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/zPa6EZ2jqb)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [flutter_distributor](#flutter_distributor)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
      - [⚠️ Linux requirements](#️-linux-requirements)
      - [⚠️ macOS requirements](#️-macos-requirements)
      - [⚠️ Windows requirements](#️-windows-requirements)
    - [CLI](#cli)
      - [Package](#package)
      - [Publish](#publish)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Quick Start

### Installation

```
dart pub global activate flutter_distributor
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

#### ⚠️ Windows requirements

- [Inno Setup](https://jrsoftware.org/isinfo.php)

### CLI

#### Package

Will package your application into a platform specific format and put the result in a folder.

| Flag         | Value                               | Required | Description |
| ------------ | ----------------------------------- | -------- | ----------- |
| `--platform` | Platform, e.g. `android`            | Yes      |             |
| `--targets`  | Comma separated list of maker names | Yes      |             |

Example:

```bash
flutter_distributor package --platform=android --targets=aab,apk
```

#### Publish

| Flag        | Value                                                     | Required | Description |
| ----------- | --------------------------------------------------------- | -------- | ----------- |
| `--path`    | path, e.g. `dist/1.0.0+1/hello_world-1.0.0+1-android.apk` | Yes      |             |
| `--targets` | Comma separated list of publisher names                   | Yes      |             |

Example:

```bash
flutter_distributor publish --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk --targets fir,pgyer
```

## License

[MIT](./LICENSE)