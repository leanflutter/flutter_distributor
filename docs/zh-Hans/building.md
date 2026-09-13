# 构建

[English](../en/building.md) | 简体中文

构建负责调用项目使用的构建系统并定位原始产物。构建结果可以直接用于测试和分析，也可以继续交给[打包器](packagers/README.md)生成可分发格式。

## 构建与打包的区别

| 操作 | 主要职责                     | 常见输出                                                   |
| ---- | ---------------------------- | ---------------------------------------------------------- |
| 构建 | 编译项目并定位原始产物       | APK、AAB、IPA、`.app`、桌面 bundle、Web 目录、HAP/APP      |
| 打包 | 调用构建器，再整理为分发格式 | APK、AAB、IPA、DMG、PKG、ZIP、EXE、MSIX、AppImage、DEB、RPM 等 |

只需要最终分发文件时，直接使用 `fastforge package`。打包流程会自动调用相应构建器，不必先手动执行 `fastforge build`。

## 当前命令边界

Fastforge 已包含 Gradle、Xcode、Flutter 和 Custom Builder，但它们接入 CLI 的方式不同：

| 构建器               | 当前入口                                        | 状态                        |
| -------------------- | ----------------------------------------------- | --------------------------- |
| Flutter Builder      | `fastforge build`、`fastforge package`、action  | 所有 Flutter 平台均已接通   |
| Gradle Android       | `fastforge package`、`fastforge/package` action | APK、AAB 已接通             |
| Xcode iOS / macOS    | `fastforge/package` action、`fastforge package` | IPA、macOS `.app` 已接通    |
| Gradle Multiplatform | 暂无顶层命令                                    | 仅构建模块可用              |
| Custom Builder       | 暂无顶层命令                                    | 仅构建模块可用              |

> [!IMPORTANT]
> `fastforge build` 始终使用 Flutter Builder，只适用于 Flutter 项目。Gradle Builder 和 Xcode Builder 只能通过 `fastforge package` 或 `fastforge/package` action 使用，详见[构建器总览](builders/README.md)。

## 单独执行构建

```bash
fastforge build [--platform <platform>] [--target <target>]
```

例如：

```bash
fastforge build --platform android --target apk
fastforge build --platform web
fastforge build --target ipa --build-export-method app-store
```

省略 `--platform` 时，会根据 `--target` 推断平台（如 `apk` → `android`、`dmg` → `macos`）。没有 target，或 target 有歧义（如 `zip`）时，Fastforge 根据项目中存在的平台目录和当前宿主能构建的平台判断，并优先选择宿主平台；仍无法确定时需要显式传入 `--platform`。部分平台要求 `--target`（Android 为 `apk`/`aab`，OpenHarmony 为 `hap`/`app`）。除非传入 `--clean`，`build` 不会执行 `flutter clean`。

支持的平台、target、构建参数、产物位置和宿主限制统一见 [Flutter Builder](builders/flutter.md)。

## 构建结果

成功后，`fastforge build` 向标准输出写入 JSON，其中包括：

- `config`：构建模式、flavor 和实际参数
- `outputDirectory`：构建输出目录
- `outputFiles`：识别到的产物路径（Windows、Linux、Web 等目录型构建为空）
- `duration`：构建耗时，单位为毫秒

如果构建命令成功但没有在预期目录找到产物（目录型构建则是输出目录不存在），Fastforge 仍会返回失败。这样可以避免后续打包或发布步骤误用空目录。

## 在打包流程中构建

在不含 `pubspec.yaml` 的项目中，Gradle Builder 和 Xcode Builder 通过 `package` 使用：

```bash
fastforge package --platform android --targets apk
```

Xcode 构建需要 `project`、`scheme` 等参数。CLI 没有对应的专用参数，推荐通过工作流 action 的 `build-args` 传入，也可以通过 `--flutter-build-args project=...,scheme=...` 传入字符串值。完整示例见 [Xcode Builder](builders/xcode.md)。

## 下一步

- 查看构建器及接入状态：[构建器总览](builders/README.md)
- 生成可分发产物：[打包](packaging.md)
- 分析构建产物：[应用包分析](tools/analyze.md)
- 组合构建、打包和发布：[本地工作流](workflows.md)
