---
title: Google Play
---

The playstore target publishes your package artifacts to the [Google Play](https://play.google.com/store/apps).

## 设置环境变量

需要设置一些环境变量才能正确运行。

```
# 获取你的服务账号密钥 https://cloud.google.com/iam/docs/keys-create-delete?hl=zh-cn
export PLAYSTORE_CREDENTIALS="your service account credentials file path"
```

## Usage

Run:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.aab \
  --targets playstore \
  --playstore-package-name 'org.leanflutter.examples.hello_world' /
```

### 配置 `distribute_options.yaml`

```yaml
output: dist/
releases:
  - name: dev
    jobs:
      - name: build-aab
        package:
          platform: android
          target: aab
          build_args:
            target-platform: android-arm
        # Publish to playstore
        publish:
          target: playstore
          args:
            package-name: org.leanflutter.examples.hello_world
```

运行:

```
flutter_distributor release --name dev
```

## 相关链接

- [创建和删除服务账号密钥](https://cloud.google.com/iam/docs/keys-create-delete?hl=zh-cn)
