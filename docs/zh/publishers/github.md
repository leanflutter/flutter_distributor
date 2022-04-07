---
title: github
---

The github target publishes your package artifacts to the [github](https://github.com/leanflutter/flutter\_distributor/releases) release.

## 设置环境变量

需要设置一些环境变量才能正确运行。

```
# 获取 token https://docs.github.com/cn/enterprise-server@3.2/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

export GITHUB_TOKEN="your personal access token"
```

## 用法

运行:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk \
  --targets github \
  --github-repo-owner 'leanflutter' \
  --github-repo-name 'flutter_distributor'
```

### 配置 `distribute_options.yaml`

```yaml
env:
  GITHUB_TOKEN: your personal access token, See[https://docs.github.com/cn/enterprise-server@3.2/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token]
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
        # Publish to github
        publish:
          target: github
          args:
            repo-owner: Repository owner
            repo-name: Repository name
```

运行:

```
flutter_distributor release --name dev
```

## 相关链接

* [创建个人 Token](https://docs.github.com/cn/enterprise-server@3.2/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
