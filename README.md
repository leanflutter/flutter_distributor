# flutter_distributor

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image] [![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

[pub-image]: https://img.shields.io/pub/v/flutter_distributor.svg?style=flat-square
[pub-url]: https://pub.dev/packages/flutter_distributor

[discord-image]: https://img.shields.io/discord/884679008049037342.svg?style=flat-square
[discord-url]: https://discord.gg/zPa6EZ2jqb

[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.flutter_distributor/visits

A complete tool for packaging and publishing your [Flutter](https://flutter.dev) apps.

---

English | [简体中文](./README-ZH.md)

---

## Documentation

The full documentation can be found on [distributor.leanflutter.org](https://distributor.leanflutter.org/).

## Features

### Makers

- [apk](./packages/flutter_app_packager/lib/src/makers/apk/) - Create a `apk` package for your app.
- [aab](./packages/flutter_app_packager/lib/src/makers/aab/) - Create a `aab` package for your app.
- [deb](./packages/flutter_app_packager/lib/src/makers/deb/) - Create a `deb` package for your app.
- [dmg](./packages/flutter_app_packager/lib/src/makers/dmg/) - Create a `dmg` package for your app.
- [exe](./packages/flutter_app_packager/lib/src/makers/exe/) - Create a `exe` package for your app.
- [ipa](./packages/flutter_app_packager/lib/src/makers/ipa/) - Create a `ipa` package for your app.
- [msix](./packages/flutter_app_packager/lib/src/makers/msix/) - Create a `msix` package for your app.
- [zip](./packages/flutter_app_packager/lib/src/makers/zip/) - Create a `zip` package for your app.

### Publishers

- [appcenter](./packages/flutter_app_publisher/lib/src/publishers/appcenter/) - Publish your app to `appcenter`.
- [appstore](./packages/flutter_app_publisher/lib/src/publishers/appstore/) - Publish your app to `appstore`.
- [fir](./packages/flutter_app_publisher/lib/src/publishers/fir/) - Publish your app to `fir`.
- [firebase](./packages/flutter_app_publisher/lib/src/publishers/firebase/) - Publish your app to `firebase`.
- [github](./packages/flutter_app_publisher/lib/src/publishers/github/) - Publish your app to `github` release.
- [pgyer](./packages/flutter_app_publisher/lib/src/publishers/pgyer/) - Publish your app to `pgyer`.
- [qiniu](./packages/flutter_app_publisher/lib/src/publishers/qiniu/) - Publish your app to `qiniu`.

## Getting Started

### Installation

```
dart pub global activate flutter_distributor
```

### Usage

Add `distribute_options.yaml` to your project root directory.

```yaml
env:
  PGYER_API_KEY: 'your api key'
output: dist/
releases:
  - name: dev
    jobs:
      # Build and publish your apk pkg to pgyer
      - name: release-dev-android
        package:
          platform: android
          target: apk
          build_args:
            target-platform: android-arm,android-arm64
            dart-define:
              APP_ENV: dev
        publish_to: pgyer
      # Build and publish your ipa pkg to pgyer
      - name: release-dev-ios
        package:
          platform: ios
          target: ipa
          build_args:
            export-options-plist: ios/dev_ExportOptions.plist
            dart-define:
              APP_ENV: dev
        publish_to: pgyer
```

> The `build_args` are the args supported by the `flutter build` command, please modify it according to your project.

#### Release Your App

```
flutter_distributor release --name dev
```

## Who's using it?

- [Biyi](https://biyidev.com/) - A convenient translation and dictionary app.
- [Qianji](https://qianjiapp.com/) - A purely bookkeeping app.
- [Alga](https://github.com/laiiihz/alga/) - A developer tools app.

## License

[MIT](./LICENSE)
