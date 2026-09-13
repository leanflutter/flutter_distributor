# Catalog synchronization

Stores App Store and Google Play metadata and images as local YAML + files
for version control, bulk editing, and repeatable publishing. Default root:
`.fastforge/stores/` (`appstore/<bundle-id>/`, `googleplay/<package-name>/`).
AppGallery has no catalog.

## Bulk (apps in `.fastforge/config.yaml`)

```bash
fastforge store list            # configured stores and apps (incl. AppGallery)
fastforge store catalog pull
fastforge store catalog push    # no --dry-run: pushes for real
```

- Runs all `stores.appstore.apps` (in config order), then all
  `stores.googleplay.apps`; AppGallery apps are skipped.
- App Store entries use `bundle_id` (fallback `app_id`) and `platform`
  (`IOS` default, `MAC_OS`, `TV_OS`, `VISION_OS`); default directories only.
- One app's failure doesn't stop the others, but any failure makes the exit
  status nonzero.
- Two App Store entries with the same bundle ID but different platforms
  share one directory, and each pull replaces it (see below) — the last one
  wins. Pull those per platform into separate `--output` roots instead.

## App Store, single app

```bash
fastforge appstore catalog pull \
  --app com.example.myapp --platform IOS [--version 1.0.0] \
  --output .fastforge/stores/appstore        # <bundle-id>/ is appended

fastforge appstore catalog push \
  --app com.example.myapp \
  --input .fastforge/stores/appstore \
  --dry-run
```

`--platform` defaults to `IOS`; without `--version` all versions of that
platform are pulled.

**Pull replaces the whole `<bundle-id>/` directory.** It builds a complete
snapshot beside it and swaps it in only on success (a failed pull leaves the
old snapshot untouched). Anything not in the new snapshot is gone: other
platforms' or versions' directories and uncommitted local edits.

Directory layout:

```text
<bundle-id>/
├── app.yaml                 # bundle ID, name, primary locale, SKU (not pushed)
├── app_info.yaml            # primary/secondary categories and subcategories
├── info/<locale>.yaml       # app-info localizations (name, subtitle, …)
├── versions/
│   └── <PLATFORM>/          # IOS, MAC_OS, TV_OS, VISION_OS
│       └── 1.0.0/
│           ├── version.yaml          # _id, platform, versionString, state, copyright
│           ├── review.yaml           # App Review contact/demo account/notes
│           ├── review.d/<id>.yaml    # review attachment metadata
│           └── en-US/
│               ├── localization.yaml # description, keywords, whatsNew, URLs, promo text
│               ├── screenshots/<DISPLAY_TYPE>/001.png …
│               └── previews/<PREVIEW_TYPE>/001_<id>.mov …
└── .manifest.yaml           # remote screenshot IDs + checksums per set
```

Pull de-duplicates across versions: per platform, versions are processed
oldest → newest, and localization fields, copyright, `review.yaml`, and
screenshot/preview sets are written only when they differ from the previous
version. Sparse version directories are normal.

Push behavior:

- `app_info.yaml` and `info/<locale>.yaml`: update, or create missing
  locales. Never deletes a remote locale.
- `version.yaml`: only `copyright` is pushed. A version directory with no
  matching remote version is skipped — push doesn't create versions.
- `localization.yaml`: changed fields are updated; missing locales are
  created; remote locales are never deleted.
- Screenshots, per display-type folder that contains files (PNG/JPEG only):
  unchanged files are reused by checksum, new ones uploaded, remote
  screenshots not present locally **deleted**, and order set by local file
  name. An empty or missing folder leaves that remote set untouched.
- Previews are pull-only (not pushed).
- `review.yaml` is updated/created; `review.d/` only updates existing
  attachments (new attachments aren't uploaded).

## Google Play, single app

```bash
fastforge googleplay catalog pull \
  --package-name com.example.myapp \
  --output .fastforge/stores/googleplay      # <package-name>/ is appended

fastforge googleplay catalog push \
  --package-name com.example.myapp \
  --input .fastforge/stores/googleplay \
  --dry-run
```

Directory layout:

```text
<package-name>/
├── app.yaml
├── listings/<language>.yaml
├── screenshots/<language>/<type>/NNN_<image-id>.<ext>
└── tracks/<track>.yaml      # ':' in track names becomes '_'
```

`<type>` is one of `phone_screenshots`, `seven_inch_screenshots`,
`ten_inch_screenshots`, `tv_screenshots`, `wear_screenshots`,
`feature_graphic`, `tv_banner`, `icon`.

Pull writes into the existing directory and never removes files, so images
deleted remotely stay locally (and would be re-uploaded). Pull into an empty
directory when you need an exact snapshot.

Push behavior (one edit, **committed automatically** at the end):

- `listings/*.yaml`: upserted; remote languages are never deleted.
- Per image-type folder that contains files: **all** remote images of that
  type/language are deleted, then local files uploaded in file-name order.
  An upload failure is only a warning, so a set can end up short. Empty or
  missing folders leave the remote images untouched.
- `tracks/*.yaml`: every file is sent as-is and replaces that track's
  releases (status, `userFraction`, release notes). A stale track file can
  change live releases — remove track files you don't intend to change.

## Safe operating sequence (always follow for push)

1. `pull` to get the latest remote state (App Store: every platform/version
   you care about, each into its own root if they'd collide; Google Play:
   into an empty directory).
2. Edit YAML and images on a separate branch.
3. Review the diff. Removing a screenshot from a non-empty folder deletes it
   remotely; removing a whole locale or folder deletes nothing remotely.
4. Preview with the store-specific `push --dry-run` — it lists planned
   actions per file, not a field-level diff (App Store lists every
   `info/` locale as "create" even if it exists).
5. Push for real only after confirmation, with the store-specific command
   when you need control over a single app.
