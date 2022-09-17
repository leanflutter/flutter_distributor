# flutter_distributor

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image] [![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

[pub-image]: https://img.shields.io/pub/v/flutter_distributor.svg?style=flat-square
[pub-url]: https://pub.dev/packages/flutter_distributor

[discord-image]: https://img.shields.io/discord/884679008049037342.svg?style=flat-square
[discord-url]: https://discord.gg/zPa6EZ2jqb

[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.flutter_distributor/visits

一个完整的工具，用于打包和发布您的 [Flutter](https://flutter.dev) 应用。

---

[English](./README.md) | 简体中文

---

## 文档

完整的文档可以在 [distributor.leanflutter.org](https://distributor.leanflutter.org/zh) 上找到。

## 功能

### 制作器

- [apk](./packages/flutter_app_packager/lib/src/makers/apk/) - 为你的应用创建一个 `apk` 包。
- [aab](./packages/flutter_app_packager/lib/src/makers/aab/) - 为你的应用创建一个 `aab` 包。
- [deb](./packages/flutter_app_packager/lib/src/makers/deb/) - 为你的应用创建一个 `deb` 包。
- [dmg](./packages/flutter_app_packager/lib/src/makers/dmg/) - 为你的应用创建一个 `dmg` 包。
- [exe](./packages/flutter_app_packager/lib/src/makers/exe/) - 为你的应用创建一个 `exe` 包。
- [ipa](./packages/flutter_app_packager/lib/src/makers/ipa/) - 为你的应用创建一个 `ipa` 包。
- [zip](./packages/flutter_app_packager/lib/src/makers/zip/) - 为你的应用创建一个 `zip` 包。
- [msix](./packages/flutter_app_packager/lib/src/makers/msix/) - 为你的应用创建一个 `msix` 包。

### 发布器

- [appcenter](./packages/flutter_app_publisher/lib/src/publishers/appcenter/) - 把你的应用发布到 `appcenter`.
- [appstore](./packages/flutter_app_publisher/lib/src/publishers/appstore/) - 把你的应用发布到 `appstore`.
- [fir](./packages/flutter_app_publisher/lib/src/publishers/fir/) - 把你的应用发布到 `fir`。
- [firebase](./packages/flutter_app_publisher/lib/src/publishers/firebase/) - 把你的应用发布到 `firebase`。
- [github](./packages/flutter_app_publisher/lib/src/publishers/github/) - 把你的应用发布到 `github` release。
- [pgyer](./packages/flutter_app_publisher/lib/src/publishers/pgyer/) - 把你的应用发布到 `pgyer`。
- [qiniu](./packages/flutter_app_publisher/lib/src/publishers/qiniu/) - 把你的应用发布到 `qiniu`。

## 立即开始

### 安装

```
dart pub global activate flutter_distributor
```

### 用法

将 `distribute_options.yaml` 添加到你的项目根目录。

```yaml
env:
  PGYER_API_KEY: 'your api key'
output: dist/
releases:
  - name: dev
    jobs:
      # 构建并发布您的 apk 包到 pgyer
      - name: release-dev-android
        package:
          platform: android
          target: apk
          build_args:
            target-platform: android-arm,android-arm64
            dart-define:
              APP_ENV: dev
        publish_to: pgyer
      # 构建并发布您的 ipa 包到 pgyer
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

> `build_args` 是 `flutter build` 命令所支持的参数，请根据你的项目进行修改。

#### 发布你的应用

```
flutter_distributor release --name dev
```

## 谁在用使用它？

- [比译](https://biyidev.com/) - 一个便捷的翻译和词典应用。
- [钱迹](https://qianjiapp.com/) - 一款纯粹记账的应用。
- [Alga](https://github.com/laiiihz/alga/) - 一个开发者工具应用。

## 许可证

[MIT](./LICENSE)
