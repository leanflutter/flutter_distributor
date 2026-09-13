# AppGallery

English | [简体中文](../../zh-Hans/publishers/appgallery.md)

The `appgallery` target uploads an app package to Huawei AppGallery Connect.

## Authentication

```bash
export APP_GALLERY_CLIENT_ID=client-id
export APP_GALLERY_CLIENT_SECRET=client-secret
```

## Publish

`app-id` is a required publishing argument, also available as the `--appgallery-app-id` option:

```bash
fastforge publish --path dist/app.aab --target appgallery \
  --publish-arg app-id=appgallery-app-id
```

You can override the environment variables with `client-id` and `client-secret` publishing arguments, but placing secrets in command history is not recommended.

The publisher obtains an access token, requests an upload URL, uploads the file, and submits package information in sequence.
