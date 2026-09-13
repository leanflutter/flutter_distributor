# GitHub Releases

English | [简体中文](../../zh-Hans/publishers/github.md)

The `github` target uploads a file to a GitHub Release. The release is found by name and created when it does not exist.

## Authentication

```bash
export GITHUB_TOKEN=github-token
```

`GITHUB_TOKEN` is required, and the token needs read and write access to releases in the target repository.

## Publish

`--path` must point to a file, not a directory:

```bash
fastforge publish --path dist/app.zip --target github \
  --publish-arg repo=owner/repository \
  --publish-arg release-title=v1.0.0 \
  --publish-arg release-tag=v1.0.0
```

In CI, `owner/repository` can be supplied through `GITHUB_REPOSITORY`.

## Release Selection

1. The release title is `release-title` when provided. Otherwise it is `v<app version>`, where the version comes from `--app-version`, the `app-version` argument, or the `version` in `./pubspec.yaml` (for example `v1.2.3+45`).
2. When a title is known, Fastforge lists the repository's releases (the first page, drafts included) and looks for one whose **name** equals the title. If none is found, it creates a release with that name, using `release-tag` as the tag (or the title when `release-tag` is omitted).
3. When there is no title and no version, the file is uploaded to the **latest** release. No release is created and `release-tag` is not used.

To target a specific release, always pass `release-title`, plus `release-tag` if the release may need to be created.

When a version is known, `release-title` may contain placeholders: `{appVersion}` and `{appBuildName}` expand to the version without pre-release or build metadata, and `{appBuildNumber}` expands to the build number.

## Arguments

| Argument             | Description                                                                          |
| -------------------- | ------------------------------------------------------------------------------------ |
| `repo`               | `owner/repository`; may also use `GITHUB_REPOSITORY`                                 |
| `release-title`      | Name of the release to find or create (supports the placeholders above)              |
| `release-tag`        | Tag used only when creating a release                                                |
| `release-draft`      | `true` or `1` creates a draft (applies only when creating)                           |
| `release-prerelease` | `true` or `1` creates a prerelease (applies only when creating)                      |
| `app-version`        | Version used for the default title; same as `--app-version`                          |
| `repo-owner`, `repo-name` | Deprecated; used only when `repo` and `GITHUB_REPOSITORY` are absent            |

## Draft and Prerelease

With `fastforge publish`, the `--github-release-draft` and `--github-release-prerelease` options default to `false` and override an unprefixed `--publish-arg release-draft=...`. Use the options instead:

```bash
fastforge publish --path dist/app.zip --target github \
  --github-repo owner/repository \
  --github-release-title v1.1.0-beta.1 \
  --publish-arg release-tag=v1.1.0-beta.1 \
  --github-release-prerelease true
```

In the `fastforge/publish` workflow action, `release-draft: "true"` works directly.

## Result

The publishing result is the asset's download URL. If the release already has an asset with the same file name, the upload fails.
