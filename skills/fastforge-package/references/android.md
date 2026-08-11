# Android packaging (APK / AAB)

## Native Gradle projects — `fastforge package`

```bash
fastforge package --platform android --target apk
fastforge package --platform android --target aab
```

Gradle Builder prefers the project's Gradle Wrapper, falling back to `gradle`
from `PATH`. Default variant is Release; the task is derived from
target + flavor + module:

| Target | No flavor | `dev` flavor |
| --- | --- | --- |
| `apk` | `assembleRelease` | `assembleDevRelease` |
| `aab` | `bundleRelease` | `bundleDevRelease` |

With a module: `:androidApp:assembleDevRelease`.

Flavor, module, and Gradle properties can only be passed through the package
action's `build-args` (a JSON object string):

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

Artifact search paths: APK `app/build/outputs/apk/`, AAB
`app/build/outputs/bundle/`. A successful Gradle run with no matching file is
treated as a build failure.

## Flutter projects — `fastforge build`

The Android packager is not connected for Flutter projects; `fastforge
package --platform android` builds and then fails. Generate the raw artifact
instead:

```bash
fastforge build --platform android --target apk
fastforge build --platform android --target aab
```

Common Flutter build options (all also apply to other Flutter platforms):

| Option | Effect |
| --- | --- |
| `--clean` | Clean before building |
| `--build-flavor <flavor>` | Product flavor |
| `--build-target <path>` | Entry point (e.g. `lib/main_prod.dart`) |
| `--build-target-platform android-arm,android-arm64` | Target ABIs |
| `--build-dart-define KEY=VALUE` | Compile-time variable, repeatable |
| `--build-obfuscate` + `--build-split-debug-info <dir>` | Obfuscation |
| `--build-tree-shake-icons` | Icon tree shaking |
| `--build-profile` | Profile mode |
| `--flutter-build-args a,b=c` | Anything else, comma-separated (no commas in values); entries without `=` are boolean switches |

Version name/number come from `pubspec.yaml` `version` via
`FLUTTER_BUILD_NAME` / `FLUTTER_BUILD_NUMBER`.

Artifacts: APK `build/app/outputs/flutter-apk/`, AAB
`build/app/outputs/bundle/`.

## Requirements & follow-ups

- Android SDK + working Gradle toolchain. APK/AAB *analysis* additionally
  needs `aapt2` under `ANDROID_HOME` (AAB: or `BUNDLETOOL`).
- Upload to Google Play goes through `fastforge googleplay bundle upload`
  (fastforge-stores skill) — there is **no** `playstore` publish target.
- fir.im / Firebase / S3 distribution of the APK: fastforge-publish skill.
