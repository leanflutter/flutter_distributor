---
title: AppImage
---

## 要求
- [AppImage Builder](https://github.com/AppImageCrafters/appimage-builder)

要安装 Appimage Builder，请运行：

```bash
wget -O appimage-builder https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.1.0/appimage-builder-1.1.0-x86_64.AppImage
chmod +x appimage-builder
mv appimage-builder /usr/local/bin/
```
> Last command may require `sudo` privileges

## 用法

将 `make_config.yaml` 添加到您的项目 `linux/packaging/appimage` 目录。

```yaml
appId: org.leanflutter.examples.hello_world
icon: assets/logo.png

script:
  - echo 'Running a Script'

include: []
exclude: []
# 默认为真
default_excludes: true

files:
  include: []
  exclude: []
  # 默认为真
  default_excludes: true
```


跑:

```bash
flutter_distributor package --platform linux --targets appimage
```

## 相关链接

* [构建和发布 Linux 应用程序](https://docs.flutter.dev/deployment/linux)
* [AppImage包格式介绍](https://docs.appimage.org/)
