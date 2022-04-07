---
title: firebase
---

The firebase target publishes your package artifacts to the [firebase](https://console.firebase.google.com/project/_/appdistribution).

## 必要条件

- `Firebase CLI`

运行以下命令

```
npm install -g firebase-tools
```

## 设置环境变量

需要设置一些环境变量才能正确运行。

```
# 获取 token https://firebase.google.com/docs/cli?authuser=0#cli-ci-systems
firebase login:ci

export FIREBASE_TOKEN="your firebase login:ci Token"
```

## 用法

运行:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk \
  --targets firebase \
  --firebase-app '<app ID>' \
  --firebase-testers testers@gmail.com \
  --firebase-groups flutter_distributor \
  --firebase-release-notes 'release v1.0.0' /
```

### 配置 `distribute_options.yaml`

```yaml
env:
  FIREBASE_TOKEN: your token, See[https://firebase.google.com/docs/cli?authuser=0#cli-ci-systems]
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
        # Publish to firebase
        publish:
          target: firebase
          args:
            app: your app ID
            testers: testers@gmail.com
            groups: flutter_distributor
            release-notes: release v1.0.0
```

运行:

```
flutter_distributor release --name dev
```

## 相关链接

- [Install the Firebase CLI](https://firebase.google.com/docs/cli?authuser=0#install_the_firebase_cli)
- [Use the CLI with CI systems](https://firebase.google.com/docs/cli?authuser=0#cli-ci-systems)
- [Use Firebase CLI - iOS](https://firebase.google.com/docs/app-distribution/ios/distribute-cli?authuser=0)
- [Use Firebase CLI - Android](https://firebase.google.com/docs/app-distribution/android/distribute-cli?authuser=0)

