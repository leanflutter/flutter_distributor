# `fastforge appstore` — App Store Connect

Calls the App Store Connect API directly. Auth is API-key only:
`APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`,
`APP_STORE_CONNECT_KEY_PATH` — all three required.

Global flags: `--json <fields>`, `--limit`, `--verbose`, `--debug`,
`--no-color`. (`--paginate` is accepted but currently has no effect.)

Platforms: `IOS`, `MAC_OS`, `TV_OS`, `VISION_OS` (wherever a `--platform`
flag exists; catalog pull defaults to `IOS`).

## Apps

```bash
fastforge appstore app list
fastforge appstore app view com.example.myapp   # bundle ID or numeric app ID
```

Neither local config nor `catalog pull` creates a remote app record.

## Builds

```bash
fastforge appstore build upload dist/MyApp.ipa --app com.example.myapp --wait
fastforge appstore build upload dist/MyApp.pkg --app com.example.myapp   # macOS
fastforge appstore build list --app com.example.myapp [--version 1.0.0]
fastforge appstore build view <build-id>
fastforge appstore build wait <build-id> [--timeout 30m]   # default 30m; units m or s
```

- Upload runs `xcrun altool` (macOS only); `.pkg` uploads as macOS, anything
  else as iOS.
- `build wait` polls every 30s until processing state is `VALID`, and fails
  on `FAILED`/`INVALID` or timeout.
- `upload --wait` uses a fixed 30m timeout and waits on the most recently
  uploaded build for the app; if the new build isn't listed yet it can pick
  an older one — prefer `build list` + `build wait <id>` when it matters.
- There are no TestFlight commands (groups, testers, beta review); use the
  raw API or App Store Connect.

## Versions

```bash
fastforge appstore version list --app com.example.myapp
fastforge appstore version view 1.0.0 --app com.example.myapp
fastforge appstore version submit 1.0.0 \
  --app com.example.myapp --build <build-id> --wait
```

`version submit` = set the version's build + create review submission
(for the version's platform) + add the `appStoreVersions` item + submit, in
one command.

- The version must already exist (`version \`X\` not found` otherwise); no
  command creates versions.
- `--build latest` picks the newest build for that version string.
- It doesn't check build processing — wait for the build first.
- `--wait` uses a fixed 30m timeout and returns once the submission reaches
  `WAITING_FOR_REVIEW`, `IN_REVIEW`, `COMPLETING`, or `COMPLETE` — it does
  not wait for approval.

## Review submissions (fine-grained control)

```bash
fastforge appstore submission list --app com.example.myapp [--platform IOS] [--state <state>]
fastforge appstore submission view <submission-id>
fastforge appstore submission create --app com.example.myapp [--platform MAC_OS]
fastforge appstore submission items <submission-id>
fastforge appstore submission add-item <submission-id> \
  --item-type appStoreVersions --item-id <version-id>
fastforge appstore submission remove-item <item-id>   # item ID from `items`
fastforge appstore submission submit <submission-id> --wait [--timeout 30m]
fastforge appstore submission cancel <submission-id>
```

`--state`: `READY_FOR_REVIEW`, `WAITING_FOR_REVIEW`, `IN_REVIEW`,
`UNRESOLVED_ISSUES`, `CANCELING`, `COMPLETING`, `COMPLETE`.

`--item-type` accepts: `appStoreVersions`, `appCustomProductPageVersions`,
`appStoreVersionExperiments`, `appStoreVersionExperimentsV2`, `appEvents`, `backgroundAssetVersions`,
`gameCenterAchievementVersions`, `gameCenterActivityVersions`,
`gameCenterChallengeVersions`, `gameCenterLeaderboardSetVersions`,
`gameCenterLeaderboardVersions`. (`add-item --help` shows only an example.)

## Catalog

`fastforge appstore catalog pull|push` — see [catalog.md](catalog.md).

## Raw API

```bash
fastforge appstore api get|post|patch|delete …
```

For resources without typed commands; prefer typed commands in automation.
