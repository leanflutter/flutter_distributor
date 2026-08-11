---
name: fastforge-package
description: >-
  Build and package apps with Fastforge: producing APK/AAB for Android, IPA for
  iOS, DMG/PKG/ZIP for macOS, and raw Flutter builds for Windows/Linux/Web/
  OpenHarmony. Use this skill whenever the user wants to build, package, or
  "打包" an app with fastforge — "package my app as a dmg", "build an apk with
  the dev flavor", "create an installer", "fastforge package fails" — even if
  they don't name a command. Covers fastforge build, fastforge package, the
  fastforge/package workflow action, builder routing (Gradle/Xcode/Flutter),
  flavors, dart-define, hooks, and artifact locations. Not for uploading
  artifacts (fastforge-publish) or store review/tracks (fastforge-stores).
---

# Fastforge Package

Turn a project into a distributable artifact. The single most important thing
this skill encodes: **coverage is uneven across project types**, and the right
command depends on what kind of project you are in. Check the matrix before
suggesting anything.

## Step 1 — Identify the project type

Routing is decided by `pubspec.yaml` in the project root plus `--platform`:

1. No `pubspec.yaml`, platform `macos`/`ios` → **Xcode Builder**
2. No `pubspec.yaml`, platform `android` → **Gradle Builder**
3. `pubspec.yaml` present (any Flutter project) → **Flutter Builder**

Always run fastforge from the actual project root — detection is intentionally
simple and a wrong cwd selects the wrong builder.

## Step 2 — Pick the entry point from the support matrix

| Project | Platform → format | What works today |
| --- | --- | --- |
| Native Android (Gradle) | `android` → `apk`, `aab` | `fastforge package` CLI or package action |
| Native iOS (Xcode) | `ios` → `ipa` | **package action only** (needs `project`/`scheme` in `build-args`) |
| Native macOS (Xcode) | `macos` → `dmg`, `pkg`, `zip` | **package action only** (same reason) |
| Flutter | `macos` → `dmg`, `pkg`, `zip` | `fastforge package` CLI or package action |
| Flutter | `android`, `ios`, `windows`, `linux`, `web`, `ohos` | **`fastforge build` only** — raw artifact, no packager connected |

Two consequences worth stating to users before they hit them:

- In a Flutter project, `fastforge package --platform android|ios` completes
  the build and then fails with `Unsupported package target`, because those
  packagers are not connected yet. Use `fastforge build` for the raw
  APK/AAB/IPA — it lands in the standard Flutter output directories and is
  perfectly publishable.
- The top-level `fastforge package` command cannot express Xcode's required
  `project`/`scheme` arguments, so native iOS/macOS packaging must go through
  a workflow's `fastforge/package` action with `build-args`.

Linux/Windows/Web/OpenHarmony packagers and the Custom/Gradle-Multiplatform
builders exist in the codebase but have no CLI entry point — for those, run
the project's own build commands (optionally as shell steps in a workflow) and
don't invent flags like `--platform custom`.

## Step 3 — Run it

One-off, single target, exploratory → run the CLI directly:

```bash
fastforge package --platform android --target apk        # native Gradle project
fastforge package --platform macos --target dmg          # Flutter project
fastforge build --platform android --target aab          # Flutter raw artifact
```

Repeatable, multi-target, flavor matrix, CI-bound, native Xcode, or the user
says they'll need it again → generate a workflow in `.fastforge/workflows/`
and run it with `fastforge workflow run`. Read
[../fastforge/references/workflow.md](../fastforge/references/workflow.md)
for syntax before writing one, validate it with `fastforge workflow validate`,
and leave the file in the project as a deliverable. This is also the only way
to set a custom output directory or `artifact-name` — the bare CLI always
writes to `dist/`.

Platform specifics (Gradle tasks and flavors, Xcode two-stage IPA export,
PKG config file, artifact search paths, `build` command options):

- Android → [references/android.md](references/android.md)
- iOS → [references/ios.md](references/ios.md)
- macOS → [references/macos.md](references/macos.md)

## The packaging lifecycle

`fastforge package` runs: detect build system → build → `hook-pre` → produce
artifact → `hook-post`. Hooks run through the system shell; a nonzero hook
exit fails the run immediately. Hooks receive `PLATFORM`, `PACKAGE_FORMAT`,
`BUILD_MODE`, `OUTPUT_DIRECTORY`, `BUILD_OUTPUT_DIRECTORY`, and
`BUILD_OUTPUT_FILES` (colon-separated) — the natural place for signing,
notarization, or artifact verification:

```bash
fastforge package --platform macos --target zip \
  --hook-pre './scripts/before.sh' --hook-post './scripts/after.sh'
```

Useful CLI options: `--skip-clean` reuses the build cache; `--build-target
lib/main_production.dart` selects a Flutter entry point.

`fastforge build` prints a JSON result (`config`, `platform`,
`outputDirectory`, `outputFiles`, `duration`). A build that succeeds but
yields no artifact in the expected directory is reported as a **failure** —
that's deliberate, so later steps never consume an empty directory.

## After packaging

- Inspect the artifact (size, tech stack, signing): `fastforge analyze` — see
  the `fastforge` skill.
- Upload it: the `fastforge-publish` skill.
- Google Play uploads are not part of packaging or publishing — they go
  through `fastforge googleplay` (the `fastforge-stores` skill).
