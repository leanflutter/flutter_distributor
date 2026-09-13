# `fastforge googleplay` — Google Play Console

Operates the Google Play Developer API. Auth:
`GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` — a file path or the complete JSON; the
service account needs Play Developer API access to the target app.

Global flags: `--json <fields>`, `--limit`, `--verbose`, `--debug`,
`--no-color`.

## Apps

```bash
fastforge googleplay app view com.example.myapp
fastforge googleplay app check com.example.myapp   # verify access
```

## The edit model

Every write happens inside an edit; nothing is visible until the edit is
committed:

```bash
fastforge googleplay edit create --package-name com.example.myapp   # → edit-id
# …mutating commands with --edit-id…
fastforge googleplay edit commit --package-name com.example.myapp --edit-id <edit-id>
fastforge googleplay edit delete --package-name com.example.myapp --edit-id <edit-id>  # abandon
```

## Upload an AAB

Within an existing edit:

```bash
fastforge googleplay bundle upload dist/app-release.aab \
  --package-name com.example.myapp --edit-id <edit-id>
```

Or the one-shot form — creates the edit, uploads, assigns a track, commits:

```bash
fastforge googleplay bundle upload dist/app-release.aab \
  --package-name com.example.myapp \
  --track internal --release-name '1.0.0 (1)' --commit
```

## Tracks

```bash
fastforge googleplay track list --package-name com.example.myapp --edit-id <edit-id>
fastforge googleplay track view internal --package-name com.example.myapp --edit-id <edit-id>
fastforge googleplay track update internal \
  --package-name com.example.myapp --edit-id <edit-id> \
  --version-code 1 --status completed
```

Track names: `internal`, `alpha`, `beta`, `production` (plus custom tracks).
Remember to `edit commit` after `track update` unless the command committed
already.

## Catalog

`fastforge googleplay catalog pull|push` — see [catalog.md](catalog.md).

## Raw API

```bash
fastforge googleplay api get|post|put|patch|delete …
```

For endpoints without typed commands; prefer typed commands in automation.
