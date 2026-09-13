---
name: fastforge
description: >-
  Fastforge fundamentals: installing and upgrading the CLI, project configuration
  (.fastforge/config.yaml), workflow file syntax and troubleshooting
  (.fastforge/workflows/*.yml, "workflow validate" failures), app package analysis
  (fastforge analyze for APK/AAB/IPA/DMG/.app size, tech stack, and signing reports),
  the local Studio web UI (fastforge studio), and general "how do I use fastforge"
  questions. Use this skill whenever fastforge is mentioned and the request is not
  clearly one of the specialized scenarios: building/packaging apps is
  fastforge-package, uploading artifacts to distribution services is
  fastforge-publish, and App Store Connect / AppGallery Connect / Google Play
  operations are fastforge-stores. Also use it when a fastforge command fails and
  the cause is unclear, or when the user asks what fastforge can do.
---

# Fastforge

Fastforge is a CLI that builds, packages, and publishes apps (Flutter, native
Android/iOS/macOS) with one configuration. This skill covers the CLI itself:
installation, configuration, workflow files, artifact analysis, and routing to
the right command or companion skill.

## Command map

| Command | Purpose | Skill to consult |
| --- | --- | --- |
| `fastforge package` / `build` | Build and package artifacts | `fastforge-package` |
| `fastforge publish` | Upload an existing artifact to a distribution target | `fastforge-publish` |
| `fastforge appstore` / `appgallery` / `googleplay` / `store` | Store operations: builds, versions, review, tracks, catalog | `fastforge-stores` |
| `fastforge workflow` | Run local YAML workflows | this skill, [references/workflow.md](references/workflow.md) |
| `fastforge analyze` | Inspect APK/AAB/IPA/DMG/.app artifacts | this skill, [references/analyze.md](references/analyze.md) |
| `fastforge studio` | Local web UI over projects (`serve`, `doctor`; `--port` 7391, `--no-open`) | this skill |
| `fastforge release` | Runs legacy `distribute_options.yaml` releases — prefer `workflow` | this skill |
| `fastforge upgrade` | Self-update from GitHub releases (`--force` reinstalls) | this skill |
| `fastforge version-check` | Check GitHub for a newer release (`--current-only`: local version, no network) | this skill |

## Installation

The CLI is a standalone binary; it does not bundle platform SDKs, build tools,
signing tools, or third-party publishing clients.

macOS / Linux (default path `/usr/local/bin/fastforge`; supports macOS
arm64/x86_64, Linux aarch64/x86_64 GNU):

```bash
curl -fsSL https://raw.githubusercontent.com/fastforgedev/fastforge/main/install.sh | sh
```

Pin a version (e.g. `0.7.0`, no `v`) or change the directory with
`FASTFORGE_VERSION` / `FASTFORGE_INSTALL_DIR`, set on the `sh` side of the pipe:
`curl -fsSL …/install.sh | FASTFORGE_VERSION=0.7.0 sh`.

Windows x86_64/ARM64 (PowerShell; installs to `%LOCALAPPDATA%\fastforge\bin` and adds it to
the user PATH):

```powershell
iwr https://raw.githubusercontent.com/fastforgedev/fastforge/main/install.ps1 | iex
```

From source: `cargo install --path apps/cli` inside a clone of
`https://github.com/fastforgedev/fastforge`. Locally built binaries print a
startup warning to distinguish them from official release builds — expected,
not an error.

Verify with `fastforge --version`. If the shell cannot find the command, check
that the install directory is in `PATH`.

To upgrade, run `fastforge upgrade`: it downloads the latest release archive for
the platform and replaces the running binary (use `sudo` if the install directory
is not writable, e.g. `/usr/local/bin`). To pin a version instead, re-run the
install script with `FASTFORGE_VERSION`. Every command first checks GitHub for a
newer release (stderr hint, 5s timeout, never fails the command); pass the global
`--no-version-check` flag to skip it, e.g. in CI. Set `GITHUB_TOKEN` to avoid API
rate limits.

Uninstall with the matching `uninstall.sh` / `uninstall.ps1`, passing the same
`FASTFORGE_INSTALL_DIR` if one was used at install time.

## Toolchain prerequisites

Fastforge shells out to platform tools. When a command fails, first check the
dependency for that operation:

| Operation | Requires |
| --- | --- |
| Android build | Android SDK, Gradle toolchain |
| APK/AAB analysis | `aapt2` under `ANDROID_HOME`/`ANDROID_SDK_ROOT` (AAB alternatively bundletool via `BUNDLETOOL` or `PATH`) |
| iOS / macOS build, DMG/.app analysis | macOS, Xcode command-line tools |
| Flutter build | Flutter SDK with `flutter` in `PATH` |
| App Store upload | macOS, `xcrun`, App Store Connect credentials |
| Firebase publishing | Firebase CLI |
| Vercel publishing | Vercel CLI |

## Project configuration

Per-project state lives under `.fastforge/` in the project root:

```text
.fastforge/
├── config.yaml      # store apps + auth for `fastforge store` and Studio
├── workflows/       # local workflow YAML files
└── stores/          # catalog data pulled from stores
```

Read [references/config.md](references/config.md) before writing or editing
`.fastforge/config.yaml`. Two rules matter everywhere: credentials are passed
through process environment variables (never CLI args, never committed), and
`auth` values may reference them as a whole-value `${ENV_NAME}`.

## Workflows

`fastforge workflow` runs GitHub-Actions-style YAML, conventionally kept in
`.fastforge/workflows/`. Workflows are the mechanism the other fastforge
skills use for anything repeatable or multi-step — read
[references/workflow.md](references/workflow.md) for the full syntax, the
`fastforge/package` and `fastforge/publish` actions, and validation before
generating or debugging any workflow file.

Quick diagnostics for a failing workflow:

1. `fastforge workflow validate <file>` — parses structure only; it does not
   execute steps, so a valid file can still fail at run time.
2. `build-args` and `publish-args` must be **JSON object strings**, not YAML
   maps — this is the most common authoring mistake.
3. Discovery covers `.fastforge/workflows/`, `.minact/workflows/` **and**
   `.github/workflows/`; if more than one file is found, `workflow run` needs an
   explicit `--file`. Files that fail to parse are silently left out of `list`.

## Artifact analysis

`fastforge analyze` reports identity, tech stack, size composition, and
signing for `.apk`, `.aab`, `.ipa`, `.dmg`, and `.app` inputs, as JSON or a
self-contained HTML report:

```bash
fastforge analyze dist/app.apk                 # JSON to stdout
fastforge analyze dist --output report.html    # scan a directory, HTML report
```

DMG and `.app` analysis run only on macOS. Read
[references/analyze.md](references/analyze.md) for per-format fields,
dependencies, and CI usage before interpreting or scripting analysis output.

## Known limitations to state plainly

- `fastforge release` exists only for legacy compatibility — steer users to
  workflows.
- The `fastforge-package` skill has the authoritative platform/format matrix;
  `--platform` is optional on `package`/`build` (inferred from targets and
  project layout when unambiguous).
