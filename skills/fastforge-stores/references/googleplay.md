# `fastforge googleplay` — Google Play Console

Operates the Google Play Developer API. Auth:
`GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` — a file path or the complete JSON; the
service account needs Play Developer API access to the target app.

Global flags: `--json <fields>`, `--limit`, `--verbose`, `--debug`,
`--no-color`.

## Apps

```bash
fastforge googleplay app view com.example.myapp    # prints package + Console URL (no API call)
fastforge googleplay app check com.example.myapp   # verify access (creates and deletes an edit)
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

- Only `.aab` files are accepted.
- Without `--edit-id` a new edit is created; without `--commit` it is left
  uncommitted (the output prints its edit ID).
- Without `--track` the bundle is uploaded but not assigned to any track.
- `--status` defaults to `completed`; `--release-name` defaults to the AAB
  file name.

## Tracks

```bash
fastforge googleplay track list --package-name com.example.myapp --edit-id <edit-id>
fastforge googleplay track view internal --package-name com.example.myapp --edit-id <edit-id>
fastforge googleplay track update internal \
  --package-name com.example.myapp --edit-id <edit-id> \
  --version-code 1 [--status completed] [--release-name '1.0.0 (1)']
fastforge googleplay edit commit --package-name com.example.myapp --edit-id <edit-id>
```

Track names: `internal`, `alpha`, `beta`, `production` (plus custom tracks).
`track update` never commits — always follow it with `edit commit`.

`track update` (and `bundle upload --track`) replaces the track's releases
with a single release containing only name, version code, and status
(`--release-name` defaults to `release <version-code>`). There are no flags
for a rollout fraction (`userFraction`) or release notes, so staged rollouts
and "what's new" text need `fastforge googleplay api …` or an edited
`tracks/<track>.yaml` pushed via catalog.

## Catalog

`fastforge googleplay catalog pull|push` — see [catalog.md](catalog.md).

## Raw API

```bash
fastforge googleplay api get|post|put|patch|delete …
```

For endpoints without typed commands; prefer typed commands in automation.
