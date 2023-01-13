---
title: RPM
---

## Requires

- [rpmbuild](https://rpm-packaging-guide.github.io/#prerequisites)

Install `rpmbuild`:

- Debian/Ubuntu: `apt install rpm`
- Fedora: `dnf install gcc rpm-build rpm-devel rpmlint make python bash coreutils diffutils patch rpmdevtools`
- Arch: `yay -S rpmdevtools` or `pamac install rpmdevtools`

## Usage

Add `make_config.yaml` to your project `linux/packaging/rpm` directory.

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

Run:

```
flutter_distributor package --platform linux --targets rpm
```

## Related Links

- [Build and release an Linux app](https://docs.flutter.dev/deployment/linux)
- [RPM packaging, how it works](https://rpm-packaging-guide.github.io/)
