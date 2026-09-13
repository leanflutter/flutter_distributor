# Publisher reference

Credentials always come from process environment variables. `--publish-arg`
is for non-sensitive parameters only. Every argument key may also be written
with a `<target>-` prefix (`github-repo`, `playstore-track`) — handy when one
command publishes to multiple comma-separated targets.

## S3-compatible storage (`s3` / `minio`, `qiniu`, `oss`, `cos`)

One shared S3 Signature V4 implementation. Common arguments: `endpoint`,
`region`, `access-key`, `secret-key`, `bucket`, `key-prefix`,
`public-base-url`, `force-path-style`.

### `s3` (alias `minio`)

```bash
export S3_ENDPOINT=https://s3.example.com
export S3_REGION=us-east-1
export S3_ACCESS_KEY=…  S3_SECRET_KEY=…  S3_BUCKET=downloads
fastforge publish --path dist/app.zip --target s3 \
  --publish-arg key-prefix=releases/1.0.0
```

Standard AWS variables also work: `AWS_REGION`, `AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` — as do `MINIO_*` variables and
Dart-style `minio-*` argument keys when targeting `minio`.

### `qiniu`

Env: `QINIU_ACCESS_KEY`, `QINIU_SECRET_KEY`, `QINIU_BUCKET`, `QINIU_REGION`
(default `cn-east-1`, endpoint derived), `QINIU_PUBLIC_BASE_URL`.

### `oss` (Alibaba Cloud)

Env: `OSS_ACCESS_KEY`, `OSS_SECRET_KEY`, `OSS_BUCKET`, `OSS_REGION`
(**required**; endpoint defaults to `oss-<region>.aliyuncs.com`).

### `cos` (Tencent Cloud)

Env: `COS_ACCESS_KEY`, `COS_SECRET_KEY`, `COS_BUCKET` (includes appid suffix),
`COS_REGION` (**required**; endpoint defaults to `cos.<region>.myqcloud.com`).

## `fir` — fir.im

```bash
export FIR_API_TOKEN=…
fastforge publish --path dist/app.apk --target fir \
  --publish-arg bundle_id=com.example.app
```

`bundle_id` is **required**. Optional: `app_name`, `version`, `build_number`.
Platform is inferred from the `.apk`/`.ipa` extension only.

## `pgyer` — 蒲公英

```bash
export PGYER_API_KEY=…
fastforge publish --path dist/app.apk --target pgyer
```

Platform inferred from the `.apk`/`.ipa` extension. Optional args mirror the
PGYER API: `oversea`, `install-type`, `password`, `description`,
`update-description`, `install-date`, `install-start-date`,
`install-end-date`, `channel-shortcut`. The result message is the app's
`http://www.pgyer.com/<build-key>` URL.

## `playstore` — Google Play upload

AAB only. Requires a service-account JSON with Play Developer API access:

```bash
export PLAYSTORE_CREDENTIALS="$PWD/service-account.json"
fastforge publish --path dist/app-release.aab --target playstore \
  --publish-arg package-name=com.example.app \
  --publish-arg track=internal
```

| Arg | Required | Meaning |
| --- | :-: | --- |
| `package-name` | yes | Play package name |
| `credentials-file` | no | Overrides `PLAYSTORE_CREDENTIALS` |
| `track` | no | Assigns the uploaded version to a track |

Creates an edit, uploads the bundle, optionally updates the track, and
commits. For staged rollouts, release notes, or track inspection use
`fastforge googleplay` (fastforge-stores skill).

## `firebase` — Firebase App Distribution

Requires the Firebase CLI. `app` is **required**.

```bash
export FIREBASE_TOKEN=…
fastforge publish --path dist/app.apk --target firebase \
  --publish-arg app=1:1234567890:android:abcdef \
  --publish-arg groups=qa-team \
  --publish-arg 'release-notes=Internal build'
```

Optional args passed through to the CLI: `release-notes`,
`release-notes-file`, `testers`, `testers-file`, `groups`, `groups-file`.

## `firebase-hosting`

`--path` is the **directory** to deploy. Fastforge generates `.firebaserc` +
`firebase.json` there, then runs `firebase deploy`.

```bash
export FIREBASE_PROJECT_ID=my-project   # or --publish-arg project-id=…
fastforge publish --path build/web --target firebase-hosting
```

`FIREBASE_TOKEN` recommended in CI; optional when the CLI is signed in.

## `github` — GitHub Releases

Uploads to a release, creating it if absent. Token needs release read/write.

```bash
export GITHUB_TOKEN=…
fastforge publish --path dist/app.zip --target github \
  --publish-arg repo=owner/repository \
  --publish-arg release-tag=v1.0.0
```

| Arg | Meaning |
| --- | --- |
| `repo` | `owner/repository`; falls back to `GITHUB_REPOSITORY` |
| `release-tag` | Always pass explicitly |
| `release-title` | Title when creating the release |
| `release-draft` / `release-prerelease` | `true`/`1` |

## `appstore` — App Store Connect upload

macOS + Xcode CLT; uses `xcrun altool`. Input: signed `.ipa` or `.pkg`.

API key auth (all three required; `APPSTORE_APIKEY`/`APPSTORE_APIISSUER` are
compatible aliases):

```bash
export APP_STORE_CONNECT_KEY_ID=ABC123DEFG
export APP_STORE_CONNECT_ISSUER_ID=00000000-0000-0000-0000-000000000000
export APP_STORE_CONNECT_KEY_PATH="$PWD/AuthKey_ABC123DEFG.p8"
fastforge publish --path dist/MyApp.ipa --target appstore
```

Or username auth: `APPSTORE_USERNAME` + `APPSTORE_PASSWORD` (app-specific
password). Upload ≠ review submission — continue in fastforge-stores.

## `appgallery` — Huawei AppGallery

```bash
export APP_GALLERY_CLIENT_ID=…  APP_GALLERY_CLIENT_SECRET=…
fastforge publish --path dist/app.aab --target appgallery \
  --publish-arg app-id=<appgallery-app-id>
```

`app-id` is **required**. Flow: token → upload URL → upload → submit package
info.

## `vercel`

Requires the Vercel CLI (signed in or token-configured). `--path` is a
directory; fastforge writes `.vercel/project.json` then runs `vercel --prod`.

```bash
export VERCEL_ORG_ID=…  VERCEL_PROJECT_ID=…
fastforge publish --path build/web --target vercel
```

Overridable via `org-id` / `project-id` args.

## `custom`

Bridges any service via a shell command (`sh -c` on macOS/Linux, `cmd /C` on
Windows):

```bash
fastforge publish --path dist/app.zip --target custom \
  --publish-arg 'command=./scripts/upload.sh' \
  --publish-arg channel=stable
```

The command reads `ARTIFACT_PATH` plus `PUBLISH_ARG_<KEY>` for every other
arg (uppercased, non-alphanumerics → `_`; `release-channel` →
`PUBLISH_ARG_RELEASE_CHANNEL`). Nonzero exit fails the publish; stdout becomes
the result `message`.
