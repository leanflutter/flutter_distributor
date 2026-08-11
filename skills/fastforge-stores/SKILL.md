---
name: fastforge-stores
description: >-
  Operate app stores with Fastforge: App Store Connect (upload builds, wait for
  processing, TestFlight, create versions, submit for review) via "fastforge
  appstore"; Google Play Console (edits, AAB uploads, internal/beta/production
  tracks, staged rollouts) via "fastforge googleplay"; and multi-store metadata/
  screenshot catalog sync via "fastforge store". Use this skill whenever the
  user wants to submit an app for review, upload to TestFlight, push an AAB to
  a Play track, promote releases, or pull/push store listings, descriptions, or
  screenshots — "提审/上架/提交审核/传内测轨道/同步商店素材" — even without
  naming a command. Not for producing artifacts (fastforge-package) or plain
  file uploads to distribution services (fastforge-publish).
---

# Fastforge Stores

Store commands manage what happens *around* an artifact: builds, versions,
review, tracks, and listing metadata. This is different from `fastforge
publish`, which only moves one file to a service.

| Entry point | Scope | Reference |
| --- | --- | --- |
| `fastforge appstore` | App Store Connect API: apps, builds, versions, review submissions, raw API | [references/appstore.md](references/appstore.md) |
| `fastforge googleplay` | Google Play Developer API: apps, edits, AAB uploads, tracks, raw API | [references/googleplay.md](references/googleplay.md) |
| `fastforge store` | All apps registered in `.fastforge/config.yaml` at once: `list`, `catalog pull`, `catalog push` | [references/catalog.md](references/catalog.md) |

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

Multi-app registration for `fastforge store` lives in
`.fastforge/config.yaml` — schema in the base fastforge skill
(`../fastforge/references/config.md`). Even with auth in the config file,
credentials are still read from the process environment.

## The two flows to know by heart

**App Store release** (upload requires macOS `xcrun`):

```bash
fastforge appstore build upload dist/MyApp.ipa --app com.example.myapp --wait
fastforge appstore version submit 1.0.0 \
  --app com.example.myapp --build <build-id> --wait
```

`version submit` bundles the whole review dance: associates the build,
creates a review submission, adds the version item, submits. Finer-grained
control (add/remove items, cancel) exists under `fastforge appstore
submission` — see the reference.

**Google Play release** — every write happens inside an *edit* (create →
mutate → commit), but `bundle upload` can collapse it:

```bash
fastforge googleplay bundle upload dist/app-release.aab \
  --package-name com.example.myapp \
  --track internal --release-name '1.0.0 (1)' --commit
```

Nothing is live until an edit is committed; a forgotten `--commit` (or
`edit commit`) is the classic "why didn't anything change" cause.

## Catalog sync (listings, screenshots, metadata)

`catalog pull` snapshots store metadata into version-controllable local YAML
+ images (default `.fastforge/stores/`); `catalog push` writes local state
back. Per-store commands take `--app`/`--package-name`; `fastforge store
catalog pull|push` iterates every configured app (one failure doesn't stop
the rest, but the exit code reflects it).

Push is destructive by nature. Follow the safe sequence — pull fresh, edit on
a branch, review the diff, `push --dry-run`, then push — detailed in
[references/catalog.md](references/catalog.md).

## Useful global flags

`appstore` and `googleplay` support `--json <fields>` (machine-readable
output for scripting), `--limit`, `--verbose`, `--debug`, `--no-color`;
`appstore` additionally `--paginate`. Options at each level are inspectable
with `--help` (e.g. `fastforge appstore submission create --help`).

## Boundaries

- Building the IPA/AAB: fastforge-package skill.
- One-shot uploads without review/track semantics (fir, Firebase, S3, GitHub
  Releases, plain `--target appstore` upload): fastforge-publish skill.
- Escape hatch for API endpoints without typed commands: `fastforge appstore
  api …` / `fastforge googleplay api …` — prefer typed commands in
  automation.
