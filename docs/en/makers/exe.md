---
title: exe
---

## Requirements

* [`Inno Setup 6`](https://jrsoftware.org/isinfo.php)``

## Usage

Add `make_config.yaml` to your project `windows/packaging/exe` directory.

```yaml
// The value of AppId uniquely identifies this application. 
// Do not use the same AppId value in installers for other applications.
app_id: 5B599538-42B1-4826-A479-AF079F21A65D
publisher: LeanFlutter
publisher_url: https://github.com/leanflutter/flutter_distributor
display_name: Hello 世界
create_desktop_icon: true
install_dir_name: HELLO-WORLD
locales:
  - en
  - zh
```

Run:

```
flutter_distributor package --platform windows --targets exe
```

## Related Links

[https://jrsoftware.org/isinfo.php](https://jrsoftware.org/isinfo.php)
