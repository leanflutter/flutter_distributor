# Linux

[English](../../en/packagers/linux.md) | 简体中文

Fastforge 支持把 Flutter Linux 应用打包为 [AppImage](#appimage)、[DEB](#deb)、[RPM](#rpm)、[Pacman](#pacman)、[ZIP 或直接复制](#zip-和-direct)。

## 当前状态

| 构建系统        | `package` 状态                                          |
| --------------- | ------------------------------------------------------- |
| Flutter Builder | AppImage、DEB、RPM、Pacman、ZIP、direct 已通过 CLI/action 接入 |

Linux 打包需要 Flutter 项目（含 `pubspec.yaml`）。构建只能在 Linux 宿主上执行；在其他宿主上，`fastforge package` 会输出警告并跳过该 target。打包器使用 bundle 目录 `build/linux/<x64|arm64>/<mode>/bundle/`，产物写入 `dist/<version>/`。

```bash
fastforge package --targets deb,appimage
```

可执行文件名读取自 `linux/CMakeLists.txt` 中的 `set(BINARY_NAME "...")`，读取不到时使用 `pubspec.yaml` 中的名称。

## 配置

AppImage、DEB、RPM 和 Pacman 分别读取可选的 `linux/packaging/<format>/make_config.yaml`，结构与 Dart CLI 一致。常用键包括 `display_name`、`package_name`、`icon`、`metainfo`、`categories`、`keywords`、`generic_name` 和 `startup_notify`。文件不存在时使用默认值；文件无法解析时打包失败。

## AppImage

需要 `appimagetool` 和 `ldd`。额外的键包括 `include`（额外的共享库，通过 `locate` 查找，此时需要安装 `locate`）和 `actions`。

## DEB

需要 `dpkg-deb`（Debian/Ubuntu 上由 `dpkg-dev` 提供）。额外的键包括 `maintainer`、`co_authors`、`priority`、`section`、`dependencies` 和 `postinstall_scripts`。

## RPM

需要 `rpmbuild` 和 `patchelf`。额外的键包括 `summary`、`group`、`vendor`、`packager`、`license`、`url`、`requires` 和 `build_arch`。

## Pacman

需要 `bsdtar` 和 `xz`，不使用 `makepkg`。额外的键包括 `maintainer`、`licenses`、`dependencies`、`optional_dependencies` 和 `postinstall_scripts`。

## ZIP 和 direct

`zip` 把 bundle 目录压缩为归档；`direct` 把它直接复制到 `dist/<version>/`。两者都不需要额外工具。

返回[打包器总览](README.md)。
