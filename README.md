# flutter_distributor

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] [![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

[pub-image]: https://img.shields.io/pub/v/flutter_distributor.svg?style=flat-square
[pub-url]: https://pub.dev/packages/flutter_distributor

[discord-image]: https://img.shields.io/discord/884679008049037342.svg?style=flat-square
[discord-url]: https://discord.gg/zPa6EZ2jqb

A complete tool for packaging and publishing your [Flutter](https://flutter.dev) apps.

---

English | [简体中文](./README-ZH.md)

---

## Documentation

The full documentation can be found on [distributor.leanflutter.org](https://distributor.leanflutter.org/).

## Features

These are the available packages in this repository.

- [app_package_maker_apk](./packages/app_package_maker_apk/) - Create a `apk` package for your app.
- [app_package_maker_aab](./packages/app_package_maker_aab/) - Create a `aab` package for your app.
- [app_package_maker_deb](./packages/app_package_maker_deb/) - Create a `deb` package for your app.
- [app_package_maker_dmg](./packages/app_package_maker_dmg/) - Create a `dmg` package for your app.
- [app_package_maker_exe](./packages/app_package_maker_exe/) - Create a `exe` package for your app.
- [app_package_maker_ipa](./packages/app_package_maker_ipa/) - Create a `ipa` package for your app.
- [app_package_maker_msix](./packages/app_package_maker_msix/) - Create a `msix` package for your app.
- [app_package_maker_zip](./packages/app_package_maker_zip/) - Create a `zip` package for your app.
- [app_package_publisher_appstore](./packages/app_package_publisher_appstore/) - Publish your app to `appstore`.
- [app_package_publisher_fir](./packages/app_package_publisher_fir/) - Publish your app to `fir`.
- [app_package_publisher_firebase](./packages/app_package_publisher_firebase/) - Publish your app to `firebase`.
- [app_package_publisher_github](./packages/app_package_publisher_github/) - Publish your app to `github` release.
- [app_package_publisher_pgyer](./packages/app_package_publisher_pgyer/) - Publish your app to `pgyer`.
- [app_package_publisher_qiniu](./packages/app_package_publisher_qiniu/) - Publish your app to `qiniu`.

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
