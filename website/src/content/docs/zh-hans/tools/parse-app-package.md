---
title: Parse App Package
---

## 安装

```
dart pub global activate parse_app_package
```

## 用法

```
parse_app_package hello_world-1.0.0+1-android.apk
```

输出：

```json
{
  "platform": "android",
  "identifier": "com.example.hello_world",
  "name": "hello_world",
  "version": "1.0.0",
  "buildNumber": 1
}
```
