# Catalog synchronization

Stores app-store metadata and images as local YAML + files for version
control, bulk editing, and repeatable publishing. Default root:
`.fastforge/stores/`.

## Bulk (all apps in `.fastforge/config.yaml`)

```bash
fastforge store list            # show configured stores and apps
fastforge store catalog pull
fastforge store catalog push
```

Apps are processed in configuration order; one app's failure doesn't stop
the others, but any failure makes the exit status nonzero.

## App Store, single app

```bash
fastforge appstore catalog pull \
  --app com.example.myapp --platform IOS \
  --output .fastforge/stores/appstore

fastforge appstore catalog push \
  --app com.example.myapp \
  --input .fastforge/stores/appstore \
  --dry-run
```

Directory layout:

```text
<bundle-id>/
├── app.yaml
├── app_info.yaml        # primary/secondary/sub categories
├── info/
├── versions/
│   └── IOS/
│       └── 1.0.0/
│           ├── version.yaml          # version-level fields
│           └── en-US/
│               ├── localization.yaml # locale-specific fields
│               ├── screenshots/
│               └── previews/
└── .manifest.yaml       # remote screenshot IDs + local verification data
```

Push orders screenshots by local file name.

## Google Play, single app

```bash
fastforge googleplay catalog pull \
  --package-name com.example.myapp \
  --output .fastforge/stores/googleplay

fastforge googleplay catalog push \
  --package-name com.example.myapp \
  --input .fastforge/stores/googleplay \
  --dry-run
```

Directory layout:

```text
<package-name>/
├── app.yaml
├── listings/
├── screenshots/
│   └── <language>/      # subdivided by type: phone, 7-inch, 10-inch, TV, Wear
└── tracks/
```

## Safe operating sequence (always follow for push)

1. `pull` to get the latest remote state.
2. Edit YAML and images on a separate branch.
3. Review the diff — deleting a locale or screenshot locally deletes it
   remotely on push.
4. Preview with the store-specific `push --dry-run`.
5. Push for real only after confirmation.
