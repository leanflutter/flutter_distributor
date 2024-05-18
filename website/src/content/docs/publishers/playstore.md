---
title: Google Play
---

The playstore target publishes your package artifacts to the [Google Play](https://play.google.com/store/apps).

## Set up environment variables

requires some environment variables set up to run correctly.

```
# Get your service account credentials https://cloud.google.com/iam/docs/keys-create-delete
export PLAYSTORE_CREDENTIALS="your service account credentials file path"
```

## Usage

Run:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.aab \
  --targets playstore \
  --playstore-package-name 'org.leanflutter.examples.hello_world' /
```

### Configure `distribute_options.yaml`

```yaml
output: dist/
releases:
  - name: dev
    jobs:
      - name: build-aab
        package:
          platform: android
          target: aab
          build_args:
            target-platform: android-arm
        # Publish to playstore
        publish:
          target: playstore
          args:
            package-name: org.leanflutter.examples.hello_world
```

Run:

```
flutter_distributor release --name dev
```

## Related Links

- [Create and delete service account keys](https://cloud.google.com/iam/docs/keys-create-delete)
