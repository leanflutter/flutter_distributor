---
name: fastforge-stores
description: >-
  Operate app stores with Fastforge: App Store Connect for iOS, macOS, tvOS,
  and visionOS (upload builds, wait for processing, submit existing versions
  for review, manage review submissions) via "fastforge appstore"; Google Play
  Console (edits, AAB uploads, internal/alpha/beta/production tracks) via
  "fastforge googleplay"; Huawei AppGallery Connect (resolve app IDs, package
  compile status, submit for review) via "fastforge appgallery"; and App Store
  / Google Play metadata/screenshot catalog sync via "fastforge store". Use
  this skill whenever the user wants to submit an app for review, push an AAB
  to a Play track, release on Huawei AppGallery, or pull/push store listings,
  descriptions, or screenshots — "提审/上架/提交审核/传内测轨道/华为应用市场/
  同步商店素材" — even without naming a command. Not for producing artifacts
  (fastforge-package) or plain file uploads to distribution services
  (fastforge-publish).
---

# Fastforge Stores

Store commands manage what happens *around* an artifact: builds, versions,
review, tracks, and listing metadata. This is different from `fastforge
publish`, which only moves one file to a service.

| Entry point | Scope | Reference |
| --- | --- | --- |
| `fastforge appstore` | App Store Connect API: apps, builds, versions, review submissions, catalog, raw API | [references/appstore.md](references/appstore.md) |
| `fastforge googleplay` | Google Play Developer API: apps, edits, AAB uploads, tracks, catalog, raw API | [references/googleplay.md](references/googleplay.md) |
| `fastforge appgallery` | AppGallery Connect API: app ID lookup, app info, packages, submit for review, raw API (no catalog) | [references/appgallery.md](references/appgallery.md) |
| `fastforge store` | Apps registered in `.fastforge/config.yaml`: `list` (all three stores), `catalog pull`/`push` (App Store and Google Play apps only) | [references/catalog.md](references/catalog.md) |

Read the relevant reference before composing commands — each documents the
exact flags and the order operations must happen in.

## Authentication (environment variables, always)

App Store Connect — API key only, all three required:

```bash
export APP_STORE_CONNECT_KEY_ID=ABC123DEFG
export APP_STORE_CONNECT_ISSUER_ID=00000000-0000-0000-0000-000000000000
export APP_STORE_CONNECT_KEY_PATH="$PWD/AuthKey_ABC123DEFG.p8"
```

Google Play — service account with Play Developer API access; the variable
takes a file path or the full JSON:

```bash
export GOOGLE_PLAY_SERVICE_ACCOUNT_JSON="$PWD/service-account.json"
```

AppGallery — service account (JSON content or path) or legacy API client:

```bash
export APP_GALLERY_SERVICE_ACCOUNT_JSON=/secure/appgallery-private.json
# or: APP_GALLERY_CLIENT_ID + APP_GALLERY_CLIENT_SECRET
```

Multi-app registration for `fastforge store` lives in
`.fastforge/config.yaml` — schema in the base fastforge skill
(`../fastforge/references/config.md`). Even with auth in the config file,
credentials are still read only from the variables above (config fallbacks
such as `APPSTORE_APIKEY` or `GOOGLE_APPLICATION_CREDENTIALS` don't count).

## The flows to know by heart

**App Store release** (upload requires macOS `xcrun`; the version must
already exist in App Store Connect — nothing here creates one):

```bash
fastforge appstore build upload dist/MyApp.ipa --app com.example.myapp --wait
fastforge appstore version submit 1.0.0 \
  --app com.example.myapp --build <build-id|latest> --wait
```

`version submit` bundles the whole review dance: associates the build,
creates a review submission, adds the version item, submits. `--wait` stops
once App Review has accepted it (waiting/in review), not at approval.
Finer-grained control (view, add/remove items, cancel) exists under
`fastforge appstore submission` — see the reference.

**Google Play release** — every write happens inside an *edit* (create →
mutate → commit), but `bundle upload` can collapse it:

```bash
fastforge googleplay bundle upload dist/app-release.aab \
  --package-name com.example.myapp \
  --track internal --release-name '1.0.0 (1)' --commit
```

Nothing is live until an edit is committed; a forgotten `--commit` (or
`edit commit`) is the classic "why didn't anything change" cause. Typed
commands have no rollout-fraction or release-notes flags — see the reference.

**AppGallery release** — upload the package with `fastforge publish`, then:

```bash
fastforge appgallery app resolve com.example.myapp        # → app ID
fastforge appgallery package status <app-id> <package-id> # compile done?
fastforge appgallery release <app-id>
```

## Catalog sync (listings, screenshots, metadata)

`catalog pull` snapshots store metadata into version-controllable local YAML
+ images (default `.fastforge/stores/<store>/<id>/`); `catalog push` writes
local state back. Per-store commands take `--app`/`--package-name`;
`fastforge store catalog pull|push` iterates configured App Store apps, then
Google Play apps (one failure doesn't stop the rest, but the exit code
reflects it). AppGallery has no catalog.

Push is destructive by nature and the aggregate `store catalog push` has no
dry-run. An App Store pull replaces the whole `<bundle-id>/` directory
(other platforms/versions and local edits included); a Google Play push also
rewrites tracks from `tracks/*.yaml`. Follow the safe sequence in
[references/catalog.md](references/catalog.md).

## Useful global flags

`appstore` and `googleplay` accept `--json <fields>` (machine-readable output
for scripting), `--limit`, `--verbose`, `--debug`, `--no-color`;
`appgallery` accepts the same except `--limit` (`package list` has its own
`--limit`/`--offset`). Options at each level are inspectable with `--help`
(e.g. `fastforge appstore submission create --help`).

## Boundaries

- Building the IPA/PKG/AAB: fastforge-package skill.
- One-shot uploads without full store semantics (fir, pgyer, Firebase, S3,
  GitHub Releases, plain `--target appstore` upload, `--target playstore`
  AAB-to-track upload, `--target appgallery` package upload):
  fastforge-publish skill. Come back here for review submission, track
  management, and metadata.
- TestFlight tester/group management and Play staged-rollout fractions have
  no typed commands; use `fastforge appstore api …` / `fastforge googleplay
  api …` (or the web console) — prefer typed commands in automation.
