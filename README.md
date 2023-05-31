# flutter_distributor

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image] [![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos) [![All Contributors][all-contributors-image]](#contributors)

[pub-image]: https://img.shields.io/pub/v/flutter_distributor.svg?style=flat-square
[pub-url]: https://pub.dev/packages/flutter_distributor
[discord-image]: https://img.shields.io/discord/884679008049037342.svg?style=flat-square
[discord-url]: https://discord.gg/zPa6EZ2jqb
[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.flutter_distributor/visits
[all-contributors-image]: https://img.shields.io/github/all-contributors/leanflutter/flutter_distributor?color=ee8449&style=flat-square

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
- [appimage](./packages/flutter_app_packager/lib/src/makers/appimage/) - Create a `AppImage` package for your app.
- [deb](./packages/flutter_app_packager/lib/src/makers/deb/) - Create a `deb` package for your app.
- [dmg](./packages/flutter_app_packager/lib/src/makers/dmg/) - Create a `dmg` package for your app.
- [exe](./packages/flutter_app_packager/lib/src/makers/exe/) - Create a `exe` package for your app.
- [ipa](./packages/flutter_app_packager/lib/src/makers/ipa/) - Create a `ipa` package for your app.
- [msix](./packages/flutter_app_packager/lib/src/makers/msix/) - Create a `msix` package for your app.
- [rpm](./packages/flutter_app_packager/lib/src/makers/rpm/) - Create a `rpm` package for your app.
- [zip](./packages/flutter_app_packager/lib/src/makers/zip/) - Create a `zip` package for your app.

### Publishers

- [appcenter](./packages/flutter_app_publisher/lib/src/publishers/appcenter/) - Publish your app to `appcenter`.
- [appstore](./packages/flutter_app_publisher/lib/src/publishers/appstore/) - Publish your app to `appstore`.
- [fir](./packages/flutter_app_publisher/lib/src/publishers/fir/) - Publish your app to `fir`.
- [firebase](./packages/flutter_app_publisher/lib/src/publishers/firebase/) - Publish your app to `firebase`.
- [firebase_hosting](./packages/flutter_app_publisher/lib/src/publishers/firebase_hosting/) - Publish your app to `firebase_hosting`.
- [github](./packages/flutter_app_publisher/lib/src/publishers/github/) - Publish your app to `github` release.
- [pgyer](./packages/flutter_app_publisher/lib/src/publishers/pgyer/) - Publish your app to `pgyer`.
- [playstore](./packages/flutter_app_publisher/lib/src/publishers/playstore/) - Publish your app to `playstore`.
- [qiniu](./packages/flutter_app_publisher/lib/src/publishers/qiniu/) - Publish your app to `qiniu`.
- [vercel](./packages/flutter_app_publisher/lib/src/publishers/vercel/) - Publish your app to `vercel`.

## Getting Started

### Installation

```
dart pub global activate flutter_distributor
```

### Usage

Add `distribute_options.yaml` to your project root directory.

```yaml
variables:
  PGYER_API_KEY: "your api key"
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

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lijy91"><img src="https://avatars.githubusercontent.com/u/3889523?v=4?s=100" width="100px;" alt="LiJianying"/><br /><sub><b>LiJianying</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=lijy91" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://juejin.cn/user/764915820276439"><img src="https://avatars.githubusercontent.com/u/8764899?v=4?s=100" width="100px;" alt="Zero"/><br /><sub><b>Zero</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=yy1300326388" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/KRTirtho"><img src="https://avatars.githubusercontent.com/u/61944859?v=4?s=100" width="100px;" alt="Kingkor Roy Tirtho"/><br /><sub><b>Kingkor Roy Tirtho</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=KRTirtho" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/laiiihz"><img src="https://avatars.githubusercontent.com/u/35956195?v=4?s=100" width="100px;" alt="LAIIIHZ"/><br /><sub><b>LAIIIHZ</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=laiiihz" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ueki-tomohiro"><img src="https://avatars.githubusercontent.com/u/27331430?v=4?s=100" width="100px;" alt="Tomohiro Ueki"/><br /><sub><b>Tomohiro Ueki</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=ueki-tomohiro" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://cybrox.eu/"><img src="https://avatars.githubusercontent.com/u/2383736?v=4?s=100" width="100px;" alt="Sven Gehring"/><br /><sub><b>Sven Gehring</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=cybrox" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/GargantuaX"><img src="https://avatars.githubusercontent.com/u/14013111?v=4?s=100" width="100px;" alt="GargantuaX"/><br /><sub><b>GargantuaX</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=GargantuaX" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/hiperioncn"><img src="https://avatars.githubusercontent.com/u/6045710?v=4?s=100" width="100px;" alt="Hiperion"/><br /><sub><b>Hiperion</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=hiperioncn" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/GroovinChip"><img src="https://avatars.githubusercontent.com/u/4250470?v=4?s=100" width="100px;" alt="Reuben Turner"/><br /><sub><b>Reuben Turner</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=GroovinChip" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://animator.github.io"><img src="https://avatars.githubusercontent.com/u/615622?v=4?s=100" width="100px;" alt="Ankit Mahato"/><br /><sub><b>Ankit Mahato</b></sub></a><br /><a href="https://github.com/leanflutter/flutter_distributor/commits?author=animator" title="Documentation">📖</a></td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td align="center" size="13px" colspan="7">
        <img src="https://raw.githubusercontent.com/all-contributors/all-contributors-cli/1b8533af435da9854653492b1327a23a4dbd0a10/assets/logo-small.svg">
          <a href="https://all-contributors.js.org/docs/en/bot/usage">Add your contributions</a>
        </img>
      </td>
    </tr>
  </tfoot>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## License

[MIT](./LICENSE)
