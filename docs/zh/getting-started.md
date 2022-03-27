---
description: Flutter Distributor 是一个完整的工具，用于打包和发布您的 Flutter 应用。
---

# 开始

## 安装

```
dart pub global activate flutter_distributor
```

## 用法

将 `distribute_options.yaml` 添加到你的项目根目录。

```yaml
output: dist/
```

### 配置一个发布器

以 `pgyer` 为例，登录后，点击右侧的用户头像，从菜单中进入[API 信息](https://www.pgyer.com/account/api)页面，复制 `API Key` 并将其添加到 `env` 节点。

![https://www.pgyer.com/account/api](.gitbook/assets/pgyer-api-info.png)

```yaml
env:
  PGYER_API_KEY: 'your api key'
```

Check out the [Publishers](configuration/publishers/) documentation for all possible publishers and how to configure them.

### 配置发布项

下面的例子展示了如何添加一个包含打包 `apk`、`ipa` 包并发布到 `pgyer.com` 的发布项，一个发布项可以包含多个作业。

{% hint style="info" %}
`build_args` 是 `flutter build` 命令所支持的参数，请根据你的项目进行修改。
{% endhint %}

```yaml
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
            export-options-plist: ios/ExportOptions.plist
            dart-define:
              APP_ENV: dev
        publish_to: pgyer
```

### 完整的示例配置

```yaml
env:
  PGYER_API_KEY: 'your api key'
output: dist/
releases:
  - name: dev
    jobs:
      # 构建 apk 包并将其发布到 pgyer
      - name: release-dev-android
        package:
          platform: android
          target: apk
          build_args:
            target-platform: android-arm,android-arm64
            dart-define:
              APP_ENV: dev
        publish_to: pgyer
      # 构建 ipa 包并将其发布到 pgyer
      - name: release-dev-ios
        package:
          platform: ios
          target: ipa
          build_args:
            export-options-plist: ios/ExportOptions.plist
            dart-define:
              APP_ENV: dev
        publish_to: pgyer
```

### 发布你的应用

```
flutter_distributor release --name dev
```

## 谢谢你

🎉 🎉 🎉
