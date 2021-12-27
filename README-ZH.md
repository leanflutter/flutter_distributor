# flutter_distributor

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/flutter_distributor.svg
[pub-url]: https://pub.dev/packages/flutter_distributor

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

一个完整的工具，用于打包和发布您的 [Flutter](https://flutter.dev) 应用。

---

[English](./README.md) | 简体中文

---

## 文档

完整的文档可以在 [distributor.leanflutter.org](https://distributor.leanflutter.org/v/zh) 上找到。

## 项目功能

这些是本代码仓库中可用的包。

- [app_package_maker_apk](./packages/app_package_maker_apk/) - 为你的应用创建一个 `apk` 包。
- [app_package_maker_aab](./packages/app_package_maker_aab/) - 为你的应用创建一个 `aab` 包。
- [app_package_maker_deb](./packages/app_package_maker_deb/) - 为你的应用创建一个 `deb` 包。
- [app_package_maker_dmg](./packages/app_package_maker_dmg/) - 为你的应用创建一个 `dmg` 包。
- [app_package_maker_exe](./packages/app_package_maker_exe/) - 为你的应用创建一个 `exe` 包。
- [app_package_maker_ipa](./packages/app_package_maker_ipa/) - 为你的应用创建一个 `ipa` 包。
- [app_package_maker_zip](./packages/app_package_maker_zip/) - 为你的应用创建一个 `zip` 包。
- [app_package_publisher_fir](./packages/app_package_publisher_fir/) - 把你的应用发布到 `fir`。
- [app_package_publisher_pgyer](./packages/app_package_publisher_pgyer/) - 把你的应用发布到 `pgyer`。

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
            target: lib/main.dart
            flavor: dev
            target-platform: android-arm,android-arm64
        publish_to: pgyer
      # 构建并发布您的 ipa 包到 pgyer
      - name: release-dev-ios
        package:
          platform: ios
          target: ipa
          build_args:
            target: lib/main.dart
            flavor: dev
            export-options-plist: ios/dev_ExportOptions.plist
        publish_to: pgyer
```

> `build_args` 是 `flutter build` 命令所支持的参数，请根据你的项目进行修改。

#### 发布你的应用

```
flutter_distributor release --name dev
```

## 许可证

[MIT](./LICENSE)
