---
title: AppImage
---

## Requirements
- [AppImage Builder](https://github.com/AppImageCrafters/appimage-builder)

To install Appimage Builder, run:

```bash
wget -O appimage-builder https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.1.0/appimage-builder-1.1.0-x86_64.AppImage
chmod +x appimage-builder
mv appimage-builder /usr/local/bin/
```
> Last command may require `sudo` privileges

## Usage

Add `make_config.yaml` to your project `linux/packaging/appimage` directory.

```yaml
appId: org.leanflutter.examples.hello_world
icon: assets/logo.png

script:
  - echo 'Running a Script'

include: []
exclude: []
# its true by default
default_excludes: true

files:
  include: []
  exclude: []
  # its true by default
  default_excludes: true
```


Run:

```bash
flutter_distributor package --platform linux --targets appimage
```

## Related Links

* [Build and release an Linux app](https://docs.flutter.dev/deployment/linux)
* [Introduction to AppImage package format](https://docs.appimage.org/)
