# Android packaging (APK / AAB)

Both project types package end-to-end:

```bash
fastforge package --targets apk,aab      # --platform android optional (inferred)
```

- **Flutter projects** (`pubspec.yaml` present) route through Flutter Builder,
  then the APK/AAB packager prepares the artifact into `dist/`.
- **Native Gradle projects** route through Gradle Builder.

## Gradle Builder details (native projects)

Prefers the project's Gradle Wrapper, falling back to `gradle` from `PATH`.
Default variant is Release; the task is derived from target + flavor + module:

| Target | No flavor | `dev` flavor |
| --- | --- | --- |
| `apk` | `assembleRelease` | `assembleDevRelease` |
| `aab` | `bundleRelease` | `bundleDevRelease` |

With a module: `:androidApp:assembleDevRelease`.

Flavor, module, and Gradle properties are passed through the package action's
`build-args` (a JSON object string):

```yaml
- name: Package Android APK
  uses: fastforge/package
  with:
    platform: android
    target: apk
    output: artifacts/
    build-args: '{"flavor":"dev","module":"app"}'
```

| `build-args` field | Meaning |
| --- | --- |
| `flavor` | Android product flavor |
| `profile` | Presence of the key selects Profile instead of Release |
| `module` | Gradle module name |
| `gradle-property` | JSON object → `-Pkey=value` |
| `system-property` | JSON object → `-Dkey=value` |

Gradle artifact search paths: APK `app/build/outputs/apk/`, AAB
`app/build/outputs/bundle/`. A successful Gradle run with no matching file is
treated as a build failure.

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
| `--clean` / `--skip-clean` | Clean (or don't) before building |
| `--build-flavor <flavor>` | Product flavor |
| `--build-target <path>` | Entry point (e.g. `lib/main_prod.dart`) |
| `--build-target-platform` | Target ABIs |
| `--build-dart-define KEY=VALUE` | Compile-time variable, repeatable |
| `--build-obfuscate` + `--build-split-debug-info <dir>` | Obfuscation (build command) |
| `--build-tree-shake-icons` | Icon tree shaking (build command) |
| `--build-profile` | Profile mode (build command) |
| `--flutter-build-args a,b=c` | Anything else, comma-separated (no commas in values); entries without `=` are boolean switches |

Version name/number come from `pubspec.yaml` `version` via
`FLUTTER_BUILD_NAME` / `FLUTTER_BUILD_NUMBER`.

Raw-artifact-only alternative (`fastforge build --platform android --target
apk|aab`) skips the packaging stage; outputs land in
`build/app/outputs/flutter-apk/` and `build/app/outputs/bundle/`.

## Requirements & follow-ups

- Android SDK + working Gradle toolchain. APK/AAB *analysis* additionally
  needs `aapt2` under `ANDROID_HOME` (AAB: or `BUNDLETOOL`).
- Upload options: `fastforge publish --target playstore` for a straight
  AAB-to-track upload, or `fastforge googleplay` for full edit/track/rollout
  control (fastforge-stores skill). fir.im / pgyer / Firebase / S3
  distribution: fastforge-publish skill.
