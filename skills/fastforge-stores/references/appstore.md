# `fastforge appstore` — App Store Connect

Calls the App Store Connect API directly. Auth is API-key only:
`APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`,
`APP_STORE_CONNECT_KEY_PATH` — all three required.

Global flags: `--json <fields>`, `--limit`, `--paginate`, `--verbose`,
`--debug`, `--no-color`.

## Apps

```bash
fastforge appstore app list
fastforge appstore app view com.example.myapp   # bundle ID or app ID
```

## Builds

```bash
fastforge appstore build upload dist/MyApp.ipa --app com.example.myapp --wait
fastforge appstore build list --app com.example.myapp
fastforge appstore build view <build-id>
fastforge appstore build wait <build-id> --timeout 30m
```

Uploads depend on macOS `xcrun`. `--wait` / `build wait` block until App
Store processing finishes — required before a build can be attached to a
version or TestFlight.

## Versions

```bash
fastforge appstore version list --app com.example.myapp
fastforge appstore version view 1.0.0 --app com.example.myapp
fastforge appstore version submit 1.0.0 \
  --app com.example.myapp --build <build-id> --wait
```

`version submit` = associate build + create review submission + add version
item + submit for review, in one command.

## Review submissions (fine-grained control)

```bash
fastforge appstore submission list --app com.example.myapp [--platform IOS] [--state <state>]
fastforge appstore submission create --app com.example.myapp --platform IOS
fastforge appstore submission items <submission-id>
fastforge appstore submission add-item <submission-id> \
  --item-type appStoreVersions --item-id <version-id>
fastforge appstore submission submit <submission-id> --wait
fastforge appstore submission cancel <submission-id>
```

`add-item --help` lists supported review resource types.

## Catalog

`fastforge appstore catalog pull|push` — see [catalog.md](catalog.md).

## Raw API

```bash
fastforge appstore api get|post|patch|delete …
```

For resources without typed commands; prefer typed commands in automation.
