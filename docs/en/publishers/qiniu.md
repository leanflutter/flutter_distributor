---
title: qiniu
---

The qiniu target publishes your package artifacts to the [qiniu.com](https://qiniu.com).

## Set up environment variables

requires some environment variables set up to run correctly.

```
export QINIU_ACCESS_KEY="your access key"
export QINIU_SECRET_KEY="your secret key"
```

## Usage

Run:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk \
  --targets qiniu \
  --qiniu-bucket your-bucket \
  --qiniu-bucket-domain https://dl.example.com \
  --qiniu-savekey-prefix myall/
```

### Configure `distribute_options.yaml`

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

Run:

```
flutter_distributor release --name dev
```
