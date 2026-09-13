---
name: fastforge-publish
description: >-
  Upload and distribute app artifacts with Fastforge: sending an APK/AAB/IPA/
  ZIP/PKG/web build to S3/MinIO/Qiniu/OSS/COS object storage, fir.im, PGYER
  (蒲公英), Firebase App Distribution, Firebase Hosting, GitHub Releases,
  App Store Connect (upload), Google Play (playstore), Huawei AppGallery,
  Vercel, or a custom upload script. Use this skill whenever the user wants to
  publish, upload, distribute, release, or "发布/上传" a built artifact with
  fastforge — including "put this zip on GitHub Releases", "send the apk to
  testers", "deploy the web build", and end-to-end "package then publish"
  release pipelines. Not for store review/version/track management
  (fastforge-stores) and not for producing the artifact (fastforge-package).
---

# Fastforge Publish

`fastforge publish` sends one existing file or directory to one or more
targets:

```bash
fastforge publish --path dist/app.zip --targets github \
  --publish-arg repo=owner/repository \
  --publish-arg release-title=v1.0.0 \
  --publish-arg release-tag=v1.0.0
```

`--path` and `--targets` (comma-separated; `--target`/`-t` are aliases) are
required. `--app-version` feeds targets that use a version (GitHub release
title, Play release name); otherwise `./pubspec.yaml`'s `version` is used when
present. Parameters are repeatable `--publish-arg KEY=VALUE`, plus Dart-style
provider flags (`--github-repo`, `--firebase-app`, `--pgyer-*`, … — see
`fastforge publish --help`). A `<target>-` prefixed key is stripped for its
target and **wins** over the unprefixed key (`github-repo` beats `repo`) —
useful when one command publishes to several targets. Upload progress renders
as a terminal progress bar (stderr TTY only).

Credentials: prefer environment variables (listed per target in
[references/publishers.md](references/publishers.md); read it before running
any publish). Several targets also accept credentials as args (`access-key`,
`client-secret`, …), but that leaks them into shell history. `fastforge
publish` sees the process environment plus the `variables` of a
`distribute_options.yaml` in the current directory.

## Choosing a target

| Goal | Target |
| --- | --- |
| Object storage / download server | `s3` / `minio`, `oss`, `cos` (S3 SigV4); `qiniu` (native Qiniu upload) |
| Tester distribution (APK/IPA) | `fir`, `pgyer`, `firebase` |
| Static web hosting | `firebase-hosting`, `vercel` (both take a directory path) |
| GitHub Releases | `github` (file path only; release picked by title, see below) |
| App Store Connect upload | `appstore` (IPA/PKG, macOS + `xcrun` required) |
| Google Play upload | `playstore` (AAB only; optional track assignment) |
| Huawei AppGallery | `appgallery` |
| Anything else | `custom` — runs your shell command with `ARTIFACT_PATH` and `PUBLISH_ARG_*` env vars |

## Boundary with store operations

Publishing means "move one artifact to a service" — and that's where it
stops. `--target appstore` uploads the build but does **not** submit for
review; `--target playstore` uploads an AAB and can set a track (full
rollout), but track inspection and store metadata live in `fastforge googleplay`
/ `appstore`, and staged rollouts or release notes need `googleplay api` or
catalog track files (fastforge-stores skill).
When a user says "release to the App Store / Play Store", plan both halves
explicitly.

## One-off vs. pipeline

A single upload → run `fastforge publish` directly.

A release that packages first, publishes to one or more targets, or will run
again (locally or in CI) → write a workflow in `.fastforge/workflows/` and run
`fastforge workflow run`. Read
[../fastforge/references/workflow.md](../fastforge/references/workflow.md)
for syntax first; validate with `fastforge workflow validate`; keep the file
in the project as the deliverable. Sketch of the canonical release pipeline:

```yaml
name: Release macOS

on:
  workflow_dispatch:
    inputs:
      tag: {description: Release tag}

jobs:
  release:
    steps:
      - name: Package
        uses: fastforge/package
        with: {platform: macos, target: zip, output: dist/}
      - name: Publish
        uses: fastforge/publish
        with:
          # a file, not a directory; package writes <output>/<app version>/<name>
          path: dist/1.0.0+1/my_app-1.0.0+1-macos.zip
          target: github
          repo: owner/repository
          release-title: "${{ inputs.tag }}"
          release-tag: "${{ inputs.tag }}"
```

The `fastforge/publish` action takes one `target`. Parameters go **either** in
a `publish-args` JSON string (string values only) **or** as bare `with` fields
(everything except `path`/`target`) — when `publish-args` is present, bare
fields are ignored. Pass `app-version` as a parameter if needed. Credentials
come from the process environment of `fastforge workflow run` (not
`distribute_options.yaml`).

`fastforge release` (legacy, Flutter projects) runs the `releases` in
`distribute_options.yaml`: each job packages, then publishes its first
artifact to `publish_to` / `publish.target` with `publish.args`. Prefer
workflows for new automation.

## Practical rules

- Publish reuses whatever artifact exists — users who already built with
  other tools can skip fastforge-package entirely.
- **GitHub release selection:** the target looks up a release **by name**
  (first page of releases, drafts included). The name is `release-title` if
  given, else `v<app-version>` (`--app-version` or `pubspec.yaml`). Found →
  upload there; not found → create it (`tag_name` = `release-tag`, else the
  title). No title and no version → upload to the **latest** release, and
  `release-tag` is ignored. To hit a specific release, pass `release-title`
  (plus `release-tag` for creation). Draft/prerelease on the CLI:
  `--github-release-draft true` / `--github-release-prerelease true` (a plain
  `--publish-arg release-draft=true` is overridden by those flags' `false`
  defaults). Uploading an asset name that already exists fails.
- `firebase` on the CLI requires the `--firebase-app` flag (a `--publish-arg
  app=` alone fails the pre-check) and `FIREBASE_TOKEN`.
- `fir` reads bundle id/name/version from the APK/IPA (override with
  `bundle_id` etc.); `fir` requires an `.apk`/`.ipa` extension, `pgyer` sends
  the extension as the build type — keep extensions honest.
- `playstore` accepts only `.aab` and needs `package-name` plus a service
  account JSON **file path** (`PLAYSTORE_CREDENTIALS`).
- `firebase`/`firebase-hosting` need the Firebase CLI installed; `vercel`
  needs the Vercel CLI, signed in or token-configured.
- In CI, GitHub `repo` can come from `GITHUB_REPOSITORY`.
- A failing publish usually means a missing env var or missing external CLI —
  check those before anything else.
