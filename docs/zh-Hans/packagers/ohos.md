# OpenHarmony

[English](../../en/packagers/ohos.md) | 简体中文

Fastforge 支持把 Flutter OpenHarmony 应用打包为 HAP 或 APP 文件。

## 当前状态

| 构建系统        | `package` 状态                 |
| --------------- | ------------------------------ |
| Flutter Builder | HAP、APP 已通过 CLI/action 接入 |

OpenHarmony 打包需要 Flutter 项目（含 `pubspec.yaml`），以及支持 OpenHarmony、提供 `flutter build hap` 和 `flutter build app` 的 Flutter SDK 与 OpenHarmony 签名配置。不限制宿主平台。

```bash
fastforge package --targets hap
fastforge package --targets app
```

打包器会把已签名的构建产物复制到 `dist/<version>/`：

| 格式 | 构建产物                                                           |
| ---- | ------------------------------------------------------------------ |
| HAP  | `ohos/entry/build/<flavor>/outputs/<flavor>/*-<flavor>-signed.hap` |
| APP  | `ohos/build/outputs/<flavor>/*-<flavor>-signed.app`                |

`<flavor>` 取自 `--build-flavor`，默认为 `default`。

返回[打包器总览](README.md)。
