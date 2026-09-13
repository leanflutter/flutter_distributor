# `fastforge appgallery` — Huawei AppGallery Connect

Calls the AppGallery Connect Publishing API directly.

## Auth

Checked in this order:

1. `APP_GALLERY_SERVICE_ACCOUNT_JSON`, else `APP_GALLERY_SERVICE_ACCOUNT_KEY`
   — service-account credential JSON content or a path to the JSON file
   (both variables accept either form). Recommended by Huawei.
2. Otherwise both `APP_GALLERY_CLIENT_ID` and `APP_GALLERY_CLIENT_SECRET`
   (legacy API client).

Global flags: `--json <fields>`, `--verbose`, `--debug`, `--no-color` (no
global `--limit`).

## Apps

```bash
fastforge appgallery app resolve com.example.myapp [com.example.other …] [--package-types <types>]
fastforge appgallery app view <app-id> [--lang en-US] [--release-type 1]
fastforge appgallery app view <app-id> --json appInfo,languages
```

`resolve` maps up to 50 package names to AppGallery app IDs; most other
commands need the app ID.

## Packages

```bash
fastforge appgallery package list <app-id> [--offset 0] [--limit 10]   # limit 1–100
fastforge appgallery package status <app-id> <package-id> [<package-id> …]
```

`package list` shows file, version, version code, and package ID;
`package status` shows the (AAB) compilation status and failure reason.

## Submit for review

```bash
fastforge appgallery release <app-id>
fastforge appgallery release <app-id> --release-time "2026-08-20T08:00:00+0800"
```

`--release-type` is passed through as the API's `releaseType` (default `1`).
Uploading the package itself is not an `appgallery` subcommand — use
`fastforge publish --target appgallery` (fastforge-publish skill), check
`package status`, then `release`.

## Catalog

None: `fastforge store list` shows configured AppGallery apps, but
`fastforge store catalog pull|push` skips them.

## Raw API

```bash
fastforge appgallery api get /api/publish/v2/app-info --query appId=<app-id>
fastforge appgallery api put /api/publish/v2/app-language-info \
  --query appId=<app-id> --input language.json
```

Methods: `get`, `post`, `put`, `patch`, `delete`. The path must start with
`/api/`; `--query KEY=VALUE` is repeatable; `--input` is a JSON body file.
