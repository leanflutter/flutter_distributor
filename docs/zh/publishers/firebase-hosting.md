---
title: firebase-hosting
---

The firebase-hosting target publishes your web artifacts to the [firebase hosting](https://firebase.google.com/docs/hosting).

## 获取发布参数

打开 [https://firebase.google.com](https://firebase.google.com/) 并登录

### 获取 `project-id`

选择你要部署的项目，打开项目设置页面，并找到 `Project ID`

## 用法

运行：

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-web \
  --targets firebase-hosting \
  --firebase-hosting-project-id your-project-id
```

### 配置 `distribute_options.yaml`

```yaml
output: dist/
releases:
  - name: dev
    jobs:
      - name: web-direct
        package:
          platform: web
          target: direct
        publish:
          target: firebase-hosting
          args:
            project-id: your-project-id
```

运行：

```
flutter_distributor release --name dev
```
