---
title: CLI
description: 如何使用 Flutter Distributor 的命令行界面（CLI）
---

# CLI

## 安装

```
dart pub global activate flutter_distributor
```

## 命令

{% hint style="info" %}
These commands are sorted in alphabetical order. The most commonly used are package, publish, and release.
{% endhint %}

### Package

将应用程序打包为特定于平台的格式，并将结果放入文件夹中。

<table><thead><tr><th>Flag</th><th>Value</th><th data-type="checkbox">Required</th></tr></thead><tbody><tr><td><code>--platform</code></td><td>平台, e.g. <code>android</code></td><td>true</td></tr><tr><td><code>--targets</code></td><td>以逗号分隔的 maker 名称列表</td><td>true</td></tr><tr><td><code>--skip-clean</code></td><td>跳过在构建之前一次</td><td>false</td></tr></tbody></table>

示例：

```
flutter_distributor package --platform=android --targets=aab,apk
```

### Publish

<table><thead><tr><th>Flag</th><th>Value</th><th data-type="checkbox">Required</th></tr></thead><tbody><tr><td><code>--path</code></td><td>路径, e.g. <code>hello_world-1.0.0+1-android.apk</code></td><td>true</td></tr><tr><td><code>--targets</code></td><td>以逗号分隔的 publisher 名称列表</td><td>true</td></tr></tbody></table>

示例：

```
flutter_distributor publish --path hello_world-1.0.0+1-android.apk --targets fir,pgyer
```

### Release

会根据配置文件（`distribute_options.yaml`），将你的应用打包成特定的格式并发布到分发平台。

<table><thead><tr><th>Flag</th><th>Value</th><th data-type="checkbox">Required</th></tr></thead><tbody><tr><td><code>--name</code></td><td>名称, e.g. <code>dev</code></td><td>true</td></tr><tr><td><code>--skip-client</code></td><td>跳过在构建之前一次</td><td>false</td></tr></tbody></table>

示例：

```
flutter_distributor release --name dev
```
