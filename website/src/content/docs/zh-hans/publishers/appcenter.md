---
title: appcenter
---

The appcenter target publishes your `.apk` or `.ipa` artifacts to the [appcenter](https://appcenter.ms).

## 设置环境变量

需要设置一些环境变量才能正确运行。

```
export APPCENTER_API_TOKEN="your api token"
```

> See: https://appcenter.ms/settings/apitokens

## 用法

运行:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk \
  --targets appcenter
  --appcenter-owner-name <owner-name> \
  --appcenter-app-name <app-name> \
  --appcenter-distribution-group <group-name>
```

### 配置 `distribute_options.yaml`

```yaml
variables:
  # See: https://appcenter.ms/settings/apitokens
  APPCENTER_API_TOKEN: <api-token>
output: dist/
releases:
  - name: dev
    jobs:
      - name: release-dev-android
        package:
          platform: android
          target: apk
          build_args:
            target-platform: android-arm
        # Publish to appcenter
        publish:
          target: appcenter
          args:
            owner-name: <owner-name>
            app-name: <app-name>
            distribution-group: <group-name>
```

运行:

```
flutter_distributor release --name dev
```

## 相关链接

- https://appcenter.ms
