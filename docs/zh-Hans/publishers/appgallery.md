# AppGallery

[English](../../en/publishers/appgallery.md) | 简体中文

`appgallery` target 上传应用包到 Huawei AppGallery Connect。

## 认证

```bash
export APP_GALLERY_CLIENT_ID=client-id
export APP_GALLERY_CLIENT_SECRET=client-secret
```

## 发布

`app-id` 为必填发布参数，也可以通过 `--appgallery-app-id` 选项传入：

```bash
fastforge publish --path dist/app.aab --target appgallery \
  --publish-arg app-id=appgallery-app-id
```

也可以用 `client-id` 和 `client-secret` 发布参数覆盖环境变量，但不建议把秘密写入命令历史。

发布器会依次获取 access token、申请上传地址、上传文件并提交包信息。
