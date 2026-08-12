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
  --publish-arg release-tag=v1.0.0
```

`--path` and `--targets` (comma-separated; `--target` is an alias) are
required; `--app-version` is available for targets that record one.
Parameters are repeatable `--publish-arg KEY=VALUE`, and Dart-style
`<target>-` prefixes are accepted and stripped (`github-repo` ≡ `repo`) —
useful when one command publishes to several targets. Upload progress renders
as a terminal progress bar (TTY only).

Credential values never go in `--publish-arg` — every target reads its
secrets from **process environment variables** (listed per target in
[references/publishers.md](references/publishers.md); read it before running
any publish).

## Choosing a target

| Goal | Target |
| --- | --- |
| Object storage / download server | `s3` (alias `minio`), `qiniu`, `oss`, `cos` |
| Tester distribution (APK/IPA) | `fir`, `pgyer`, `firebase` |
| Static web hosting | `firebase-hosting`, `vercel` (both take a directory path) |
| GitHub Releases | `github` (creates the release if missing) |
| App Store Connect upload | `appstore` (IPA/PKG, macOS + `xcrun` required) |
| Google Play upload | `playstore` (AAB only; optional track assignment) |
| Huawei AppGallery | `appgallery` |
| Anything else | `custom` — runs your shell command with `ARTIFACT_PATH` and `PUBLISH_ARG_*` env vars |

## Boundary with store operations

Publishing means "move one artifact to a service" — and that's where it
stops. `--target appstore` uploads the build but does **not** submit for
review; `--target playstore` uploads an AAB and can set a track, but staged
rollouts, release notes, track inspection, and store metadata live in
`fastforge googleplay` / `appstore` (fastforge-stores skill). When a user
says "release to the App Store / Play Store", plan both halves explicitly.

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
          path: dist/
          target: github
          repo: owner/repository
          release-tag: "${{ inputs.tag }}"
```

In the `fastforge/publish` action, parameters go in a `publish-args` JSON
string or as bare `with` fields (everything except `path`/`target`).
Credentials still come from the environment of the `fastforge workflow run`
process.

## Practical rules

- Publish reuses whatever artifact exists — users who already built with
  other tools can skip fastforge-package entirely.
- `fir` requires `bundle_id`; `fir` and `pgyer` infer platform from the
  `.apk`/`.ipa` extension; keep extensions honest.
- `playstore` accepts only `.aab` and needs `package-name` plus a service
  account (`PLAYSTORE_CREDENTIALS`).
- `firebase`/`firebase-hosting` need the Firebase CLI installed; `vercel`
  needs the Vercel CLI, signed in or token-configured.
- For `github`, always pass `release-tag` explicitly for predictable behavior;
  in CI, `repo` can come from `GITHUB_REPOSITORY`.
- A failing publish usually means a missing env var or missing external CLI —
  check those before anything else.
