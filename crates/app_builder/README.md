# app_builder

A Rust implementation of Fastforge's Flutter build orchestration layer.

## Features

- Dart-compatible build argument encoding
- Dart-compatible build result JSON shape
- Multi-platform builder registry
- Automatic `--build-name` and `--build-number` arguments from the `pubspec.yaml` version (unless passed explicitly)
- `FLUTTER_ROOT` support

## Supported Build Targets

- `android/apk`
- `android/aab`
- `ios/ipa` (macOS host only)
- `macos` (macOS host only)
- `windows` (Windows host only)
- `linux` (Linux host only)
- `web`
- `ohos/hap`
- `ohos/app`

## API Usage

```rust
use app_builder::FlutterAppBuilder;
use serde_json::{Map, Value, json};

fn run_build() -> anyhow::Result<()> {
    let builder = FlutterAppBuilder::default();

    let mut args = Map::<String, Value>::new();
    args.insert("flavor".into(), Value::String("dev".into()));
    args.insert("dart-define".into(), json!({
        "APP_ENV": "dev"
    }));

    let result = builder.build("android", Some("apk"), args, None)?;
    println!("{}", result.to_json_compatible());

    Ok(())
}
```

## Argument Encoding Rules

Same behavior as Dart implementation:

- `null` or `bool` => `--key`
- `string/number` => `--key value`
- `object/map` => repeated `--key subKey=value`

## iOS Validation

For `ios/ipa`, at least one of the following is required:

- `export-options-plist`
- `export-method`

## Run Tests

```bash
cargo test -p app_builder --offline
```

