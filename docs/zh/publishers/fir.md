# fir

The fir target publishes your `.apk` or `.ipa` artifacts to the [fir.im](https://betaqr.com).

## 设置环境变量

需要设置一些环境变量才能正确运行。

```
export FIR_API_TOKEN="your api token"
```

## 用法

运行：

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk \
  --targets fir
```
