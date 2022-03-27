# pgyer

The pgyer target publishes your `.apk` or `.ipa` artifacts to the [pgyer.com](https://pgyer.com).

## 设置环境变量

需要设置一些环境变量才能正确运行。

```
export PGYER_API_KEY="your api key"
```

## 用法

运行：

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk \
  --targets pgyer
```
