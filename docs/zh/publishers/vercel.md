---
title: vercel
---

The vercel target publishes your web artifacts to the [vercel.com](https://vercel.com).

## 获取发布参数

打开 [vercel.com](https://vercel.com) 并登录

### 获取 `org-id`

打开账户设置页面，并找到 `Your ID`

### 获取 `project-id`

打开项目设置页面，并找到 `Project ID`

## 用法

运行：

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-web \
  --targets vercel \
  --org-id your-org-id \
  --project-id your-project-id
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
          target: vercel
          args:
            org-id: your-org-id
            project-id: your-project-id
```

运行：

```
flutter_distributor release --name dev
```
