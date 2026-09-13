# Linux

English | [简体中文](../../zh-Hans/packagers/linux.md)

Fastforge packages Flutter Linux applications as [AppImage](#appimage), [DEB](#deb), [RPM](#rpm), [Pacman](#pacman), [ZIP, or a direct copy](#zip-and-direct).

## Current Status

| Build system    | `package` status                                              |
| --------------- | ------------------------------------------------------------- |
| Flutter Builder | AppImage, DEB, RPM, Pacman, ZIP, and direct through CLI/action |

Linux packaging requires a Flutter project (`pubspec.yaml`). The build runs only on a Linux host; on other hosts `fastforge package` skips the target with a warning. The packagers use the bundle directory `build/linux/<x64|arm64>/<mode>/bundle/`, and artifacts are written to `dist/<version>/`.

```bash
fastforge package --targets deb,appimage
```

The executable name is read from `set(BINARY_NAME "...")` in `linux/CMakeLists.txt`, falling back to the `pubspec.yaml` name.

## Configuration

AppImage, DEB, RPM, and Pacman each read an optional `linux/packaging/<format>/make_config.yaml` that follows the Dart CLI schema. Common keys include `display_name`, `package_name`, `icon`, `metainfo`, `categories`, `keywords`, `generic_name`, and `startup_notify`. Missing files use defaults; files that cannot be parsed fail packaging.

## AppImage

Requires `appimagetool` and `ldd`. Additional keys include `include` (extra shared objects, resolved with `locate`, which must then be installed) and `actions`.

## DEB

Requires `dpkg-deb` (`dpkg-dev` on Debian/Ubuntu). Additional keys include `maintainer`, `co_authors`, `priority`, `section`, `dependencies`, and `postinstall_scripts`.

## RPM

Requires `rpmbuild` and `patchelf`. Additional keys include `summary`, `group`, `vendor`, `packager`, `license`, `url`, `requires`, and `build_arch`.

## Pacman

Requires `bsdtar` and `xz`; `makepkg` is not used. Additional keys include `maintainer`, `licenses`, `dependencies`, `optional_dependencies`, and `postinstall_scripts`.

## ZIP and direct

`zip` archives the bundle directory; `direct` copies it to `dist/<version>/` without an archive. Both need no extra tools.

Return to the [packager overview](README.md).
