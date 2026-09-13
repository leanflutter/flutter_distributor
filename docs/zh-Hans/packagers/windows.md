# Windows

[English](../../en/packagers/windows.md) | 简体中文

Fastforge 支持把 Flutter Windows 应用打包为 [EXE](#exe)、[MSIX](#msix)、[ZIP 或直接复制](#zip-和-direct)。

## 当前状态

| 构建系统        | `package` 状态                           |
| --------------- | ---------------------------------------- |
| Flutter Builder | EXE、MSIX、ZIP、direct 已通过 CLI/action 接入 |

Windows 打包需要 Flutter 项目（含 `pubspec.yaml`）。构建只能在 Windows 宿主上执行；在其他宿主上，`fastforge package` 会输出警告并跳过该 target。打包器使用 runner 目录 `build/windows/<arch>/runner/<Mode>/`（Flutter 3.15 以前为 `build/windows/runner/<Mode>/`），产物写入 `dist/<version>/`。

```bash
fastforge package --targets exe,zip
```

## EXE

EXE 使用 Inno Setup 生成安装程序。它是唯一被标记为安装包的格式，因此默认产物名以 `-setup.exe` 结尾。

环境要求：Inno Setup 6。Fastforge 会运行 `INNO_SETUP_PATH`（来自环境变量或 `distribute_options.yaml` 变量）所指目录中的 `ISCC.exe`，默认位置为 `C:\Program Files (x86)\Inno Setup 6`。

可选配置：`windows/packaging/exe/make_config.yaml`，常用键包括 `app_id`、`publisher_name`、`publisher_url`、`display_name`、`executable_name`、`install_dir_name`、`setup_icon_file`、`locales`、`create_desktop_icon`、`launch_at_startup`、`privileges_required` 和 `script_template`。

## MSIX

MSIX 读取可选的 `windows/packaging/msix/make_config.yaml`，键与 `msix` pub 包一致，例如 `display_name`、`publisher_display_name`、`identity_name`、`msix_version`、`logo_path`、`capabilities`、`certificate_path`、`certificate_password`、`publisher` 和 `signtool_options`。

- 项目依赖 `msix` 包时，Fastforge 使用这些配置运行 `dart run msix:create`。
- 否则使用 Windows SDK 工具 `makeappx` 和 `signtool`，并把 `pubspec.yaml` 中的 `msix_config` 合并到 `make_config.yaml` 之下。未提供 `certificate_path` 或 `signtool_options` 时，生成的包不会签名，并输出警告。

## ZIP 和 direct

`zip` 把 runner 目录压缩为归档；`direct` 把它直接复制到 `dist/<version>/`。两者都不需要额外工具。

返回[打包器总览](README.md)。
