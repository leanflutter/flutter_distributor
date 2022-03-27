# fir

The fir target publishes your `.apk` or `.ipa` artifacts to the [fir.im](https://betaqr.com).

## Set up environment variables

requires some environment variables set up to run correctly.

```
export FIR_API_TOKEN="your api token"
```

## Usage

Run:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk \
  --targets fir
```
