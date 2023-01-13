---
title: RPM
---

## 要求

- [rpmbuild](https://rpm-packaging-guide.github.io/#prerequisites)

安装 `rpmbuild`:
- Debian/Ubuntu: `apt install rpm`
- Fedora: `dnf install gcc rpm-build rpm-devel rpmlint make python bash coreutils diffutils patch rpmdevtools`
- Arch: `yay -S rpmdevtools` or `pamac install rpmdevtools`

## 用法

将 `make_config.yaml` 添加到您的项目 `linux/packaging/rpm` 目录。

```yaml
icon: assets/logo.png
summary: A really cool application
group: Application/Emulator
vendor: Kingkor Roy Tirtho
packager: Kingkor Roy Tirtho
packagerEmail: krtirtho@gmail.com
license: GPLv3
url: https://github.com/leanflutter/flutter_distributor

display_name: Hello World

keywords:
  - Hello
  - World
  - Test
  - Application

generic_name: Cool Application

categories:
  - Cool
  - Awesome

startup_notify: true
```

跑:

```
flutter_distributor package --platform linux --targets deb
```

## 相关链接

* [构建和发布 Linux 应用程序](https://docs.flutter.dev/deployment/linux)
* [RPM 打包，它是如何工作的](https://rpm-packaging-guide.github.io/)
