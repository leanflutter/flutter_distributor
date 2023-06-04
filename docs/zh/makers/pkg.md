---
title: pkg
---

> 你只能在 macOS 机器上构建 PKG 目标。

## 用法

将 `make_config.yaml` 添加到你的项目 `macos/packaging/pkg` 目录。

```yaml
install-path: /Applications
sign-identity: <your-sign-identity>
```

运行：

```
flutter_distributor package --platform macos --targets pkg
```

## 相关链接

- [Build and release a macOS app](https://docs.flutter.dev/deployment/macos)
