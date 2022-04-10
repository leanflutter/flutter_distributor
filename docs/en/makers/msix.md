---
title: msix
---

## Usage

Add this to your package's `pubspec.yaml` file:

```yaml
dev_dependencies:
  msix: any
```

Add `make_config.yaml` to your project `windows/packaging/msix` directory.

```yaml
display_name: HelloWorld
msix_version: 1.0.0.0
# logo_path: C:\path\to\logo.png
```

> View all configuration: [msix](https://github.com/YehudaKremer/msix)

Run:

```
flutter_distributor package --platform windows --targets msix
```

## Related Links

https://github.com/YehudaKremer/msix