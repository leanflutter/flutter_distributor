# App Store Connect

[English](../../en/stores/appstore.md) | 简体中文

`fastforge appstore` 直接调用 App Store Connect API，覆盖应用查询、构建上传、版本提交、审核 submission 和 catalog。

## 认证

```bash
export APP_STORE_CONNECT_KEY_ID=ABC123DEFG
export APP_STORE_CONNECT_ISSUER_ID=00000000-0000-0000-0000-000000000000
export APP_STORE_CONNECT_KEY_PATH="$PWD/AuthKey_ABC123DEFG.p8"
```

三个变量均为必填。商店 API 命令只使用 API Key 认证。

使用 `direnv` 的项目要注意：非交互 shell、CI 和 Agent 工具不会执行交互 shell hook。只检查变量是否已设置，不要输出凭证值；后续所有 App Store 命令都保持在同一环境中运行：

```bash
direnv status
direnv exec . fastforge appstore app view com.example.myapp
```

`direnv exec .` 也会发现父目录中的 `.envrc`。这样可避免误用全局凭证而查询到另一个 App Store Connect 团队。

## 应用

```bash
fastforge appstore app list
fastforge appstore app view com.example.myapp
```

`view` 接受 bundle id 或 App Store app id。

“建立 Store 档案”可能指三种不同操作：

1. 在 `.fastforge/config.yaml` 本地登记已有应用，供 `fastforge store` 聚合命令使用。
2. 对已有远端应用执行 `catalog pull`，建立本地元数据快照。
3. 在 App Store Connect 新建远端应用记录。本地登记和 `catalog pull` 都不会创建远端应用。

## 构建

```bash
fastforge appstore build upload dist/MyApp.ipa \
  --app com.example.myapp \
  --wait

fastforge appstore build list --app com.example.myapp
fastforge appstore build view <build-id>
fastforge appstore build wait <build-id> --timeout 30m
```

上传依赖 macOS `xcrun`。`wait` 会等待 App Store 完成构建处理。

## 版本

```bash
fastforge appstore version list --app com.example.myapp
fastforge appstore version view 1.0.0 --app com.example.myapp
fastforge appstore version submit 1.0.0 \
  --app com.example.myapp \
  --build <build-id> \
  --wait
```

`version submit` 会关联构建、创建审核 submission、添加版本 item 并提交审核。

## 审核 submission

```bash
fastforge appstore submission list --app com.example.myapp
fastforge appstore submission create \
  --app com.example.myapp \
  --platform IOS
fastforge appstore submission items <submission-id>
fastforge appstore submission add-item <submission-id> \
  --item-type appStoreVersions \
  --item-id <version-id>
fastforge appstore submission submit <submission-id> --wait
fastforge appstore submission cancel <submission-id>
```

`list` 可以按 `--platform` 和 `--state` 筛选。具体可审核资源类型使用 `add-item --help` 查看。

## Catalog

App Store 的元数据、分类、截图和 preview 见[统一 Catalog](catalog.md)。

## 原始 API

```bash
fastforge appstore api get --help
fastforge appstore api post --help
fastforge appstore api patch --help
fastforge appstore api delete --help
```

原始 API 适合尚未封装的 App Store Connect 资源；自动化脚本应优先使用已有的类型化命令。
