# GitHub Releases

[English](../../en/publishers/github.md) | 简体中文

`github` target 把文件上传到 GitHub Release。Release 按名称查找，不存在时会创建。

## 认证

```bash
export GITHUB_TOKEN=github-token
```

`GITHUB_TOKEN` 为必填，Token 需要目标仓库 Release 的读写权限。

## 发布

`--path` 必须指向文件，不能是目录：

```bash
fastforge publish --path dist/app.zip --target github \
  --publish-arg repo=owner/repository \
  --publish-arg release-title=v1.0.0 \
  --publish-arg release-tag=v1.0.0
```

CI 中可以通过 `GITHUB_REPOSITORY` 提供 `owner/repository`。

## Release 的选择方式

1. 提供了 `release-title` 时，以它作为 Release 标题；否则标题为 `v<应用版本>`，版本依次取自 `--app-version`、`app-version` 参数或 `./pubspec.yaml` 中的 `version`（例如 `v1.2.3+45`）。
2. 有标题时，Fastforge 列出仓库的 Release（第一页，包含草稿），查找**名称**等于该标题的 Release；找不到则以该名称创建 Release，tag 使用 `release-tag`（省略时使用标题）。
3. 既没有标题也没有版本时，文件会上传到**最新**的 Release，不会创建 Release，`release-tag` 也不会生效。

要发布到指定 Release，请始终传入 `release-title`；如果该 Release 可能需要新建，再同时传入 `release-tag`。

已知版本时，`release-title` 可以使用占位符：`{appVersion}` 和 `{appBuildName}` 替换为不含预发布和构建元数据的版本号，`{appBuildNumber}` 替换为构建号。

## 参数

| 参数                      | 说明                                                        |
| ------------------------- | ----------------------------------------------------------- |
| `repo`                    | `owner/repository`；也可用 `GITHUB_REPOSITORY`              |
| `release-title`           | 要查找或创建的 Release 名称（支持上述占位符）               |
| `release-tag`             | 仅在创建 Release 时使用的 tag                               |
| `release-draft`           | `true` 或 `1` 表示草稿（仅在创建时生效）                    |
| `release-prerelease`      | `true` 或 `1` 表示预发布（仅在创建时生效）                  |
| `app-version`             | 默认标题使用的版本，等同于 `--app-version`                  |
| `repo-owner`、`repo-name` | 已弃用；仅在没有 `repo` 和 `GITHUB_REPOSITORY` 时使用       |

## 草稿与预发布

使用 `fastforge publish` 时，`--github-release-draft` 和 `--github-release-prerelease` 选项默认为 `false`，会覆盖不带前缀的 `--publish-arg release-draft=...`。请改用这两个选项：

```bash
fastforge publish --path dist/app.zip --target github \
  --github-repo owner/repository \
  --github-release-title v1.1.0-beta.1 \
  --publish-arg release-tag=v1.1.0-beta.1 \
  --github-release-prerelease true
```

在 `fastforge/publish` 工作流 action 中，可以直接使用 `release-draft: "true"`。

## 结果

发布结果为产物的下载地址。如果 Release 中已有同名文件，上传会失败。
