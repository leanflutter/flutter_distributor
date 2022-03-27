# pgyer

The pgyer target publishes your `.apk` or `.ipa` artifacts to the [pgyer.com](https://pgyer.com).

## Set up environment variables

requires some environment variables set up to run correctly.

```
export PGYER_API_KEY="your api key"
```

## Usage

Run:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk \
  --targets pgyer
```
