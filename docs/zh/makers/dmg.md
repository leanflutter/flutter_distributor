# dmg

{% hint style="warning" %}
你只能在 macOS 机器上构建 DMG 目标。
{% endhint %}

## 必要条件

* `appdmg`

运行以下命令

```
npm install -g appdmg
```

## 用法

将 `make_config.yaml` 添加到你的项目 `macos/packaging/dmg` 目录。

```yaml
title: hello_world
contents:
  - x: 448
    y: 344
    type: link
    path: "/Applications"
  - x: 192
    y: 344
    type: file
    path: hello_world.app
```

运行：

```
flutter_distributor package --platform macos --targets dmg
```

## 相关链接

* [https://github.com/LinusU/node-appdmg](https://github.com/LinusU/node-appdmg)
* [Build and release a macOS app](https://docs.flutter.dev/deployment/macos)
