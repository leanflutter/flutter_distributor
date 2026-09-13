# Android packaging (APK / AAB)

Both project types package end-to-end:

```bash
fastforge package --targets apk,aab      # --platform android optional (inferred)
```

- **Flutter projects** (`pubspec.yaml` present) route through Flutter Builder,
  then the APK/AAB packager copies the artifact to
  `dist/<version>/<artifact name>` (see SKILL.md for naming).
- **Native Gradle projects** route through Gradle Builder. Android builds once
  per target (no build reuse across `apk,aab`).

## Gradle Builder details (native projects)

Prefers the project's Gradle Wrapper (`./gradlew`, `gradlew.bat` on Windows),
falling back to `gradle` from `PATH`. Default variant is Release; the task is
derived from target + flavor + module:

| Target | No flavor | `dev` flavor |
| --- | --- | --- |
| `apk` | `assembleRelease` | `assembleDevRelease` |
| `aab` | `bundleRelease` | `bundleDevRelease` |

With a module: `:androidApp:assembleDevRelease`.

On the CLI, `--build-flavor dev` works for native projects too, and string
arguments go through `--flutter-build-args` (e.g. `module=app,profile`). JSON
object arguments need the package action's `build-args`:

```yaml
- name: Package Android APK
  uses: fastforge/package
  with:
    platform: android
    target: apk
    output: artifacts/
    build-args: '{"flavor":"dev","module":"app","gradle-property":{"versionCode":"42"}}'
```

| `build-args` field | Meaning |
| --- | --- |
| `flavor` | Android product flavor |
| `profile` | Presence of the key (any value) selects Profile instead of Release |
| `module` | Gradle module name (task prefix only — see caveats) |
| `gradle-property` | JSON object → `-Pkey=value` |
| `system-property` | JSON object → `-Dkey=value` |

Gradle artifact search paths: APK `app/build/outputs/apk/[<flavor>/]<mode>/*.apk`,
AAB `app/build/outputs/bundle/<mode>` or `…/bundle/<flavor><Mode>/*.aab`. A
successful Gradle run with no matching file is treated as a build failure.

Caveats (native Gradle):

- Output paths are hardcoded to the `app/` module. With `module` set to
  anything else the task runs, but artifact lookup fails.
- After the build, app metadata (`applicationId`, `versionName`,
  `versionCode`) is read from `app/build.gradle.kts`; a Groovy-only
  `app/build.gradle` project fails at this step.
- Channel and flavor are not used in the artifact name; `flutter clean` is not
  run.

## Flutter Builder details

On the CLI, flavor and friends are first-class flags:

```bash
fastforge package --targets apk \
  --build-flavor dev \
  --build-dart-define APP_ENV=dev \
  --build-target-platform android-arm,android-arm64
```

| Option | Effect |
| --- | --- |
| `--skip-clean` (package) / `--clean` (build) | `package` runs `flutter clean` unless skipped; `build` cleans only with `--clean` |
| `--build-flavor <flavor>` | Product flavor |
| `--build-target <path>` | Entry point (e.g. `lib/main_prod.dart`) |
| `--build-target-platform` | Target ABIs |
| `--build-dart-define KEY=VALUE` | Compile-time variable, repeatable |
| `--build-obfuscate` + `--build-split-debug-info <dir>` | Obfuscation (build command; on package use `--flutter-build-args obfuscate,split-debug-info=<dir>`) |
| `--build-tree-shake-icons` | Icon tree shaking (build command) |
| `--build-profile` | Profile mode (build command; on package use `--flutter-build-args profile`) |
| `--flutter-build-args a,b=c` | Anything else, comma-separated (no commas in values); entries without `=` are boolean switches |

Version name/number come from `pubspec.yaml` `version`: fastforge appends
`--build-name` / `--build-number` to `flutter build` unless you pass those
keys yourself.

Raw-artifact-only alternative (`fastforge build --platform android --target
apk|aab`) skips the packaging stage; outputs land in
`build/app/outputs/flutter-apk/` and `build/app/outputs/bundle/`.

## Requirements & follow-ups

- Android SDK + working Gradle toolchain. APK/AAB *analysis* additionally
  needs `aapt2` under `ANDROID_HOME` (AAB: or `BUNDLETOOL`).
- Upload options: `fastforge publish --targets playstore` for a straight
  AAB-to-track upload, or `fastforge googleplay` for full edit/track/rollout
  control (fastforge-stores skill). fir.im / pgyer / Firebase / S3
  distribution: fastforge-publish skill.
