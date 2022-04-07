---
title: Distribute Options
---

## Example

```yaml
env:
  PGYER_API_KEY: 'your api key'
output: dist/
releases:
  - name: dev
    jobs:
      # Build and publish your apk pkg to pgyer
      - name: release-dev-android
        package:
          platform: android
          target: apk
          build_args:
            flavor: dev
            target-platform: android-arm,android-arm64
            dart-define:
              APP_ENV: dev
        publish_to: pgyer
      # Build and publish your ipa pkg to pgyer
      - name: release-dev-ios
        package:
          platform: ios
          target: ipa
          build_args:
            flavor: dev
            export-options-plist: ios/dev_ExportOptions.plist
            dart-define:
              APP_ENV: dev
        publish_to: pgyer
```

## Specification <a href="#specification" id="specification"></a>

| Field Name | Type      | Description            |
| ---------- | --------- | ---------------------- |
| `env`      | `map`     | environment variables. |
| `output`   | `string`  | e.g. `dist/`           |
| `releases` |           |                        |

