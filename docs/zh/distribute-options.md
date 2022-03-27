# 分发选项

## 示例

```yaml
env:
  PGYER_API_KEY: 'your api key'
output: dist/
releases:
  - name: dev
    jobs:
      # 构建 apk 包并将其发布到 pgyer
      - name: release-dev-android
        package:
          platform: android
          target: apk
          build_args:
            target-platform: android-arm,android-arm64
            dart-define:
              APP_ENV: dev
        publish_to: pgyer
      # 构建 ipa 包并将其发布到 pgyer
      - name: release-dev-ios
        package:
          platform: ios
          target: ipa
          build_args:
            export-options-plist: ios/ExportOptions.plist
            dart-define:
              APP_ENV: dev
        publish_to: pgyer
```

## Specification <a href="#specification" id="specification"></a>

| Field Name | Type     | Description            |
| ---------- | -------- | ---------------------- |
| `env`      | `map`    | environment variables. |
| `output`   | `string` | e.g. `dist/`           |
| `releases` |          |                        |
