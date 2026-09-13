# 华为 AppGallery Connect

[English](../../en/stores/appgallery.md) | 简体中文

`fastforge appgallery` 直接调用 AppGallery Connect Publishing API。生成的客户端覆盖应用查询与元数据、软件包查询、上传准备和提交审核。

CLI 提供 `app`、`package`、`release` 和 `api` 子命令，全局选项为 `--json <FIELDS>`、`--verbose`、`--debug` 和 `--no-color`。上传软件包由 `fastforge publish --target appgallery` 负责；AppGallery 不参与 [catalog 同步](catalog.md)。

## 认证

华为目前推荐 Service Account。将 `APP_GALLERY_SERVICE_ACCOUNT_JSON` 设置为下载的凭证 JSON 内容或文件路径：

```bash
export APP_GALLERY_SERVICE_ACCOUNT_JSON=/secure/appgallery-private.json
```

也可以使用别名 `APP_GALLERY_SERVICE_ACCOUNT_KEY`，格式相同（JSON 内容或文件路径）；优先读取 `APP_GALLERY_SERVICE_ACCOUNT_JSON`。

同时兼容旧版 API Client：

```bash
export APP_GALLERY_CLIENT_ID=client-id
export APP_GALLERY_CLIENT_SECRET=client-secret
```

两者同时存在时优先使用 Service Account。

## 应用

```bash
fastforge appgallery app resolve com.example.myapp
fastforge appgallery app view <app-id>
fastforge appgallery app view <app-id> --lang zh-CN --json appInfo,languages
```

- `app resolve` 最多接受 50 个包名，并将其映射为 AppGallery 应用 ID；`--package-types` 会原样传给 API。
- `app view` 支持 `--lang` 和 `--release-type`（默认 `1`）。

## 软件包

```bash
fastforge appgallery package list <app-id>
fastforge appgallery package status <app-id> <package-id>
```

- `package list` 支持 `--offset`（默认 `0`）和 `--limit`（默认 `10`，范围 1–100），显示每个软件包的文件名、版本、version code、软件包 ID 和大小。
- `package status` 接受一个或多个软件包 ID，显示 AAB 编译状态与失败原因。

## 提交审核

```bash
fastforge appgallery release <app-id>
fastforge appgallery release <app-id> --release-time "2026-08-20T08:00:00+0800"
```

`--release-type` 会作为 API 的 `releaseType` 原样传递（默认 `1`）。常见流程是先用 `fastforge publish --target appgallery` 上传，再用 `package status` 确认编译完成，最后执行 `release`。

## 原始 API

尚未提供类型化命令的接口可通过已认证的相对路径调用：

```bash
fastforge appgallery api get /api/publish/v2/app-info \
  --query appId=<app-id>
fastforge appgallery api put /api/publish/v2/app-language-info \
  --query appId=<app-id> --input language.json
```

支持的方法为 `get`、`post`、`put`、`patch` 和 `delete`。路径必须以 `/api/` 开头，`--query KEY=VALUE` 可重复使用，`--input` 指向 JSON 请求体文件。

仓库内维护的源规范是 [`scripts/generate/specs/app_gallery_connect.openapi.yaml`](../../../scripts/generate/specs/app_gallery_connect.openapi.yaml)。华为当前提供 HTML API 参考而非可下载的统一 OAS 文件，因此本项目依据官方文档维护标准化的 OpenAPI 3 文件，并使用以下命令重新生成：

```bash
python3 scripts/generate/app_gallery_connect.py
```

官方文档：[快速入门](https://developer.huawei.com/consumer/cn/doc/appgallery-connect-guides/agcapi-getstarted-0000001111845114)、[查询应用信息](https://developer.huawei.com/consumer/cn/doc/AppGallery-connect-References/agcapi-app-info-query-0000001158365045)。
