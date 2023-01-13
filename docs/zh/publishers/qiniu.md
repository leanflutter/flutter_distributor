---
title: qiniu
---

The qiniu target publishes your package artifacts to the [qiniu.com](https://qiniu.com).

## 设置环境变量

需要设置一些环境变量才能正确运行。

```
export QINIU_ACCESS_KEY="your access key"
export QINIU_SECRET_KEY="your secret key"
```

## 用法

运行：

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk \
  --targets qiniu \
  --qiniu-bucket your-bucket \
  --qiniu-bucket-domain https://dl.example.com \
  --qiniu-savekey-prefix myall/
```

### 配置 `distribute_options.yaml`

```yaml
env:
  QINIU_ACCESS_KEY: your access key
  QINIU_SECRET_KEY: your secret key
output: dist/
releases:
  - name: dev
    jobs:
      - name: release-dev-android
        package:
          platform: android
          target: apk
        # Publish to qiniu
        publish:
          target: qiniu
          args:
            bucket: your bucket
            bucket-domain: https://dl.example.com
            savekey-prefix: myapp/
```

运行：

```
flutter_distributor release --name dev
```
