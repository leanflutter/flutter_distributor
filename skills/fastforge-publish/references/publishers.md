# Publisher reference

Prefer environment variables for credentials; many targets also accept them
as args, but args end up in shell history. On `fastforge publish` the
environment is the process environment plus `distribute_options.yaml`
`variables` (which override). Every argument key may also be written with a
`<target>-` prefix (`github-repo`, `playstore-track`); for its target the
prefixed key wins over the unprefixed one — handy when one command publishes to
multiple comma-separated targets. The Dart-style provider flags
(`--github-repo`, `--pgyer-password`, …) become such prefixed keys.

## S3-compatible storage (`s3` / `minio`, `oss`, `cos`)

One shared S3 Signature V4 upload. Arguments: `endpoint`, `region`,
`access-key`, `secret-key`, `bucket`, `key-prefix` (alias `savekey-prefix`;
joined with `/`), `public-base-url` (alias `bucket-domain`),
`force-path-style` (`true/false/1/0/yes/no/on/off`). The result is
`<public-base-url>/<key>` or else the upload URL.

### `s3` / `minio`

```bash
export S3_ENDPOINT=https://s3.example.com
export S3_ACCESS_KEY=…  S3_SECRET_KEY=…  S3_BUCKET=downloads
fastforge publish --path dist/app.zip --target s3 \
  --publish-arg key-prefix=releases/1.0.0
```

| Setting | Env fallback | Default |
| --- | --- | --- |
| `endpoint` | `S3_ENDPOINT`, `MINIO_ENDPOINT` | required (`https://` added if no scheme) |
| `region` | `S3_REGION`, `AWS_REGION` | `us-east-1` |
| `access-key` | `S3_ACCESS_KEY`, `AWS_ACCESS_KEY_ID`, `MINIO_ACCESS_KEY` | required |
| `secret-key` | `S3_SECRET_KEY`, `AWS_SECRET_ACCESS_KEY`, `MINIO_SECRET_KEY` | required |
| `bucket` | `S3_BUCKET` | required |
| `key-prefix` | `S3_KEY_PREFIX` | none |
| `public-base-url` | `S3_PUBLIC_BASE_URL` | upload URL |
| `force-path-style` | `S3_FORCE_PATH_STYLE` | `true` |
| `session-token` | `AWS_SESSION_TOKEN` | none |

`minio` is the same upload, but reads `MINIO_ENDPOINT` / `MINIO_ACCESS_KEY` /
`MINIO_SECRET_KEY` first. There is no `MINIO_BUCKET` or `MINIO_REGION`; use
`--minio-bucket`, `--minio-region`, `--minio-savekey-prefix` (or `S3_*`).

### `oss` (Alibaba Cloud)

Env: `OSS_ACCESS_KEY`, `OSS_SECRET_KEY`, `OSS_BUCKET`, `OSS_REGION`
(**required**), optional `OSS_KEY_PREFIX`, `OSS_PUBLIC_BASE_URL`,
`OSS_FORCE_PATH_STYLE` (default `false`). Endpoint (arg only) defaults to
`oss-<region>.aliyuncs.com`.

### `cos` (Tencent Cloud)

Env: `COS_ACCESS_KEY`, `COS_SECRET_KEY`, `COS_BUCKET` (includes appid suffix),
`COS_REGION` (**required**), optional `COS_KEY_PREFIX`,
`COS_PUBLIC_BASE_URL`, `COS_FORCE_PATH_STYLE` (default `false`). Endpoint (arg
only) defaults to `cos.<region>.myqcloud.com`.

## `qiniu`

Not S3: uses Qiniu's native form upload with an upload token; the upload host
is auto-detected for the bucket. No region/endpoint settings.

```bash
export QINIU_ACCESS_KEY=…  QINIU_SECRET_KEY=…  QINIU_BUCKET=downloads
export QINIU_PUBLIC_BASE_URL=https://download.example.com
fastforge publish --path dist/app.zip --target qiniu \
  --publish-arg savekey-prefix=releases/1.0.0/
```

Args: `access-key`, `secret-key`, `bucket`, `bucket-domain` /
`public-base-url` (env `QINIU_PUBLIC_BASE_URL`), `savekey-prefix` /
`key-prefix` (arg only, **plain concatenation** — include the trailing `/`).
The result is `<bucket-domain>/<key>`; without a domain it is literally
`<bucketDomain>/<key>`.

## `fir` — fir.im

```bash
export FIR_API_TOKEN=…
fastforge publish --path dist/app.apk --target fir
```

Bundle id, app name, version, and build number are read from the APK/IPA.
Optional overrides: `bundle_id`, `app_name`, `version`, `build_number`
(hyphenated forms also accepted); if parsing fails, `bundle_id` lets the upload
continue. The path must end in `.apk` or `.ipa`. The result is the fir
download URL with `?release_id=…`.

## `pgyer` — 蒲公英

```bash
export PGYER_API_KEY=…
fastforge publish --path dist/app.apk --target pgyer \
  --pgyer-install-type 2 --pgyer-password 1234
```

The file extension is sent as PGYER's `buildType`. Optional args (or
`--pgyer-<name>` flags) mirror the PGYER API: `oversea` (1|2),
`install-type` (1|2|3), `password`, `description`, `update-description`,
`install-date` (1|2), `install-start-date`, `install-end-date`,
`channel-shortcut`. Numeric fields with non-numeric values are dropped. After
upload fastforge polls build info (up to 10 × 3s); the result message is
`http://www.pgyer.com/<build-key>`.

## `playstore` — Google Play upload

AAB only. Requires a service-account JSON **file** with Play Developer API
access (`PLAYSTORE_CREDENTIALS` is a path, not JSON content):

```bash
export PLAYSTORE_CREDENTIALS="$PWD/service-account.json"
fastforge publish --path dist/app-release.aab --target playstore \
  --publish-arg package-name=com.example.app \
  --publish-arg track=internal
```

| Arg | Required | Meaning |
| --- | :-: | --- |
| `package-name` | yes | Play package name (`--playstore-package-name`) |
| `credentials-file` | no | Overrides `PLAYSTORE_CREDENTIALS` |
| `track` | no | Assigns the uploaded version code to a track (`--playstore-track`) |

Creates an edit, uploads the bundle, optionally sets the track release
(status `completed`, i.e. full rollout; name from the file name or app
version), and commits. For track inspection use `fastforge googleplay`; staged
rollouts and release notes need `googleplay api` or catalog track files
(fastforge-stores skill).

## `firebase` — Firebase App Distribution

Requires the Firebase CLI and `FIREBASE_TOKEN` (hard error without it). The
app id is **required**; on `fastforge publish` it must be given with
`--firebase-app` (the CLI pre-check ignores `--publish-arg app=`). In a
workflow or `fastforge release`, pass `app` as a parameter.

```bash
export FIREBASE_TOKEN=…
fastforge publish --path dist/app.apk --target firebase \
  --firebase-app 1:1234567890:android:abcdef \
  --firebase-groups qa-team \
  --firebase-release-notes 'Internal build'
```

Optional args passed through to `firebase appdistribution:distribute`:
`release-notes`, `release-notes-file`, `testers`, `testers-file`, `groups`,
`groups-file` (flags: `--firebase-<name>`).

## `firebase-hosting`

`--path` is the **directory** to deploy. Fastforge writes `.firebaserc` +
`firebase.json` there, then runs `firebase deploy` in it.

```bash
export FIREBASE_PROJECT_ID=my-project   # or --firebase-hosting-project-id / project-id arg
fastforge publish --path build/web --target firebase-hosting
```

The project id is required. `FIREBASE_TOKEN` is passed when set (recommended in
CI); optional when the CLI is signed in. The result is the `Hosting URL`.

## `github` — GitHub Releases

`GITHUB_TOKEN` (required) needs release read/write. `--path` must be a
**file**.

```bash
export GITHUB_TOKEN=…
fastforge publish --path dist/app.zip --target github \
  --github-repo owner/repository \
  --github-release-title v1.0.0 \
  --publish-arg release-tag=v1.0.0 \
  --github-release-prerelease true
```

How the release is chosen:

1. Title = `release-title` if given (placeholders `{appVersion}`,
   `{appBuildName}` → version core, `{appBuildNumber}` → build number, when a
   version is known); otherwise `v<app-version>` (full text, e.g.
   `v1.2.3+45`) from `--app-version` / `app-version` arg / `./pubspec.yaml`.
2. With a title: list releases (first page, drafts included) and match by
   **name**; if none matches, create one with `tag_name` = `release-tag` (else
   the title), plus draft/prerelease flags.
3. No title and no version: upload to the **latest** release; nothing is
   created and `release-tag` is unused.

| Arg | Meaning |
| --- | --- |
| `repo` | `owner/repository`; falls back to `GITHUB_REPOSITORY` (deprecated: `repo-owner` + `repo-name`) |
| `release-title` | Release name to find or create (template, see above) |
| `release-tag` | Tag used only when creating the release |
| `release-draft` / `release-prerelease` | `true`/`1`; only applied when creating |
| `app-version` | Version for the default title (same as `--app-version`) |

On `fastforge publish`, `--github-release-draft` / `--github-release-prerelease`
default to `false` and override an unprefixed `--publish-arg release-draft=…`;
use the flags (or `github-release-draft=true`). In workflows the plain
`release-draft: "true"` works. An existing asset with the same file name makes
the upload fail. The result is the asset download URL.

## `appstore` — App Store Connect upload

macOS + Xcode CLT; uses `xcrun altool --upload-app`. Input: signed `.ipa`
(`--type ios`) or `.pkg` / other (`--type osx`).

API key auth — key ID and issuer ID are required together; the key path is
optional:

```bash
export APP_STORE_CONNECT_KEY_ID=ABC123DEFG          # or APPSTORE_APIKEY (read first)
export APP_STORE_CONNECT_ISSUER_ID=00000000-0000-0000-0000-000000000000  # or APPSTORE_APIISSUER
export APP_STORE_CONNECT_KEY_PATH="$PWD/AuthKey_ABC123DEFG.p8"            # optional
fastforge publish --path dist/MyApp.ipa --target appstore
```

Without a key path, altool looks for `AuthKey_<id>.p8` in its default
`private_keys` folders; with one, fastforge stages the key in a temporary
`private_keys` folder for the upload.

Or username auth: `APPSTORE_USERNAME` + `APPSTORE_PASSWORD` (app-specific
password), both required together. Args `key-id`/`api-key`,
`issuer-id`/`api-issuer`, `key-path`, `username`, `password` also work.
Upload ≠ review submission — continue in fastforge-stores.

## `appgallery` — Huawei AppGallery

```bash
export APP_GALLERY_CLIENT_ID=…  APP_GALLERY_CLIENT_SECRET=…
fastforge publish --path dist/app.aab --target appgallery \
  --appgallery-app-id <appgallery-app-id>
```

`app-id` is **required** (`--appgallery-app-id` or `--publish-arg app-id=`).
`client-id` / `client-secret` args override the env. Flow: token → upload URL →
upload → submit package info.

## `vercel`

Requires the Vercel CLI (signed in or token-configured). `--path` is a
directory; fastforge writes `.vercel/project.json` then runs `vercel --prod`
in it. The result is the `Production:` URL.

```bash
export VERCEL_ORG_ID=…  VERCEL_PROJECT_ID=…
fastforge publish --path build/web --target vercel
```

Both ids are required; override with `org-id` / `project-id` args
(`--vercel-org-id` / `--vercel-project-id`).

## `custom`

Bridges any service via a shell command (`sh -c` on macOS/Linux, `cmd /C` on
Windows):

```bash
fastforge publish --path dist/app.zip --target custom \
  --publish-arg 'command=./scripts/upload.sh' \
  --publish-arg channel=stable
```

The command reads `ARTIFACT_PATH` plus `PUBLISH_ARG_<KEY>` for every other
resolved arg (uppercased, non-alphanumerics → `_`; `release-channel` →
`PUBLISH_ARG_RELEASE_CHANNEL`), including `app-version` and any flag defaults.
Output is captured, not streamed. Nonzero exit fails the publish (stdout and
stderr are included in the error); trimmed stdout becomes the result
`message`.
