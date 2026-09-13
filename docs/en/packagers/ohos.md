# OpenHarmony

English | [简体中文](../../zh-Hans/packagers/ohos.md)

Fastforge packages Flutter OpenHarmony applications as HAP or APP files.

## Current Status

| Build system    | `package` status                 |
| --------------- | -------------------------------- |
| Flutter Builder | HAP and APP through CLI/action   |

OpenHarmony packaging requires a Flutter project (`pubspec.yaml`) and a Flutter SDK with OpenHarmony support that provides `flutter build hap` and `flutter build app`, plus the OpenHarmony signing configuration. No fixed host is enforced.

```bash
fastforge package --targets hap
fastforge package --targets app
```

The packager copies the signed build artifact to `dist/<version>/`:

| Format | Build artifact                                                    |
| ------ | ----------------------------------------------------------------- |
| HAP    | `ohos/entry/build/<flavor>/outputs/<flavor>/*-<flavor>-signed.hap` |
| APP    | `ohos/build/outputs/<flavor>/*-<flavor>-signed.app`                |

`<flavor>` comes from `--build-flavor` and defaults to `default`.

Return to the [packager overview](README.md).
