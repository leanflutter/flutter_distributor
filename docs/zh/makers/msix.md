---
title: msix
---

## 用法

将此添加到你的软件包的 `pubspec.yaml` 文件：

```yaml
dev_dependencies:
  msix: any
```

将 `make_config.yaml` 添加到你的项目 `windows/packaging/msix` 目录。

```yaml
display_name: HelloWorld
msix_version: 1.0.0.0
# logo_path: C:\path\to\logo.png
```

> 查看所有配置：[msix](https://github.com/YehudaKremer/msix)

运行：

```
flutter_distributor package --platform windows --targets msix
```

## 相关链接

https://github.com/YehudaKremer/msix
