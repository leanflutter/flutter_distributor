# 发布

[English](../en/publishing.md) | 简体中文

`publish` 用于把已经存在的文件或目录发送到一个或多个发布目标。

## 基本用法

```bash
fastforge publish \
  --path dist/my-app.apk \
  --target fir
```

`--path` 和 `--targets` 为必填参数（`--target` 与 `-t` 是别名；多个 target 用逗号分隔）。发布参数使用可重复的 `--publish-arg KEY=VALUE`：

```bash
fastforge publish \
  --path dist/app.zip \
  --target github \
  --publish-arg repo=owner/repository \
  --publish-arg release-title=v1.0.0 \
  --publish-arg release-tag=v1.0.0
```

`--app-version` 为需要版本号的 target 提供版本（例如 GitHub Release 的默认标题）；省略时，如果存在 `./pubspec.yaml`，会使用其中的 `version`。

同样支持 Dart CLI 的各发布器选项，例如 `--github-repo`、`--firebase-app`、`--pgyer-password`、`--playstore-track`，它们会以 `<target>-<name>` 形式转发。任意参数键都可以带 `<target>-` 前缀：对该 target 会去掉前缀，且带前缀的键优先于不带前缀的同名键。一条命令发布到多个 target 时这很有用。

可用 target、各自的参数和凭证要求见[发布器总览](publishers/README.md)，也可以通过 `fastforge publish --help` 查看各发布器选项。

## 凭证

凭证优先通过环境变量传入。部分发布器也接受以参数形式传入凭证（例如 `access-key`、`client-secret`），但这会留在命令历史中，应尽量避免，也不要把密钥提交到版本库。`fastforge publish` 读取进程环境变量，以及当前目录 `distribute_options.yaml` 中的 `variables`（后者优先）。各 target 读取的环境变量见对应发布器页面。

## 多步骤自动化

需要组合构建、打包、发布和 shell 命令时，使用[本地工作流](workflows.md)。`fastforge/publish` action 每次只发布到一个 `target`。非敏感参数可以写成 `publish-args` JSON 字符串（值只能是字符串），也可以直接写成 `with` 字段；提供 `publish-args` 时，其他 `with` 字段会被忽略。action 只从 `fastforge workflow run` 进程的环境变量读取凭证。

旧版 `fastforge release` 命令运行 `distribute_options.yaml` 中的 releases：每个 job 先打包，设置了 `publish_to` 或 `publish.target` 时，再用 `publish.args` 中的参数发布第一个产物。新的自动化建议使用工作流。
