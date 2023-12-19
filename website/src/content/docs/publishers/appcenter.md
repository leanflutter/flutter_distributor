---
title: appcenter
---

The appcenter target publishes your `.apk` or `.ipa` artifacts to the [appcenter](https://appcenter.ms).

## Set up environment variables

requires some environment variables set up to run correctly.

```
export APPCENTER_API_TOKEN="your api token"
```

> See: https://appcenter.ms/settings/apitokens

## Usage

Run:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk \
  --targets appcenter
  --appcenter-owner-name <owner-name> \
  --appcenter-app-name <app-name> \
  --appcenter-distribution-group <group-name>
```

### Configure `distribute_options.yaml`

```yaml
variables:
  # See: https://appcenter.ms/settings/apitokens
  APPCENTER_API_TOKEN: <api-token>
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
        # Publish to appcenter
        publish:
          target: appcenter
          args:
            owner-name: <owner-name>
            app-name: <app-name>
            distribution-group: <group-name>
```

Run:

```
flutter_distributor release --name dev
```

## Related Links

- https://appcenter.ms
