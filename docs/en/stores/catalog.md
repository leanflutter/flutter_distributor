# Unified Catalog

English | [简体中文](../../zh-Hans/stores/catalog.md)

Catalog synchronization stores app-store metadata and images in a local directory for version control, bulk editing, and repeatable publishing.

## Bulk Synchronization

First register apps in `.fastforge/config.yaml`, then run:

```bash
fastforge store catalog pull
fastforge store catalog push
```

The command processes all applications in configuration order. A failure for one application does not stop subsequent applications, but the process exits with an error if any application failed.

## Default Directory

```text
.fastforge/stores/
├── appstore/
│   └── com.example.myapp/
└── googleplay/
    └── com.example.myapp/
```

## Synchronize App Store Separately

```bash
fastforge appstore catalog pull \
  --app com.example.myapp \
  --platform MAC_OS \
  --version 1.0.0 \
  --output .fastforge/stores/appstore

fastforge appstore catalog push \
  --app com.example.myapp \
  --input .fastforge/stores/appstore \
  --dry-run
```

Directory structure:

```text
<bundle-id>/
├── app.yaml
├── app_info.yaml
├── info/
├── versions/
│   └── IOS/
│       └── 1.0.0/
│           ├── version.yaml
│           └── en-US/
│               ├── localization.yaml
│               ├── screenshots/
│               └── previews/
└── .manifest.yaml
```

- `app_info.yaml` manages primary, secondary, and subcategories.
- `version.yaml` stores version-level fields.
- `localization.yaml` stores locale-specific fields.
- `.manifest.yaml` stores remote screenshot IDs and local verification data.
- Push orders screenshots by local file name; use `--dry-run` before synchronizing.
- Aggregate `fastforge store catalog pull` uses `apps[].platform` from configuration; old configurations default to `IOS`.

## Synchronize Google Play Separately

```bash
fastforge googleplay catalog pull \
  --package-name com.example.myapp \
  --output .fastforge/stores/googleplay

fastforge googleplay catalog push \
  --package-name com.example.myapp \
  --input .fastforge/stores/googleplay \
  --dry-run
```

Directory structure:

```text
<package-name>/
├── app.yaml
├── listings/
├── screenshots/
│   └── <language>/
└── tracks/
```

Google Play screenshots are further divided by language and image type, including phone, 7-inch, 10-inch, TV, and Wear.

## Safe Operating Sequence

1. Run `pull` to retrieve the latest remote state.
2. Edit YAML and images on a separate branch.
3. Review the diff to avoid unintentionally deleting locales or screenshots.
4. Preview with the individual store command's `push --dry-run`.
5. Run the actual push after confirmation.

Catalog pull stages a complete snapshot beside the destination and replaces the destination only after every required request and write succeeds. A failed pull discards its staged files and preserves the previous snapshot. When using older or unofficial binaries without this behavior, a failed pull may leave partial files: do not push, and first confirm the expected version directories and `.manifest.yaml` (when screenshots exist), or pull again into a new directory.
