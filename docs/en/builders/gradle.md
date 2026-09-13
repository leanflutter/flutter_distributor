# Gradle Builder

English | [简体中文](../../zh-Hans/builders/gradle.md)

Gradle Builder currently builds APK and AAB artifacts for native Android projects (projects without `pubspec.yaml`). It prefers the Gradle Wrapper in the project root (`./gradlew`, or `gradlew.bat` on Windows) and falls back to `gradle` from `PATH` when no wrapper is found.

## Current Integration

| Type                  | Target                       | CLI status                   |
| --------------------- | ---------------------------- | ---------------------------- |
| Android               | `apk`                        | `package` and package action |
| Android               | `aab`                        | `package` and package action |
| Multiplatform Android | `android-apk`, `android-aab` | No top-level CLI integration |
| Multiplatform Desktop | `desktop`                    | No top-level CLI integration |
| Multiplatform iOS     | `ios-framework`              | No top-level CLI integration |

## Android Builds

When packaging directly, Fastforge runs the Gradle build automatically:

```bash
fastforge package --targets apk
fastforge package --targets apk,aab --build-flavor dev
```

Each target runs its own Gradle build. `flutter clean` is not run for native projects.

The default build uses the Release variant. The Gradle task is generated from the target, flavor, and module:

| Target | No flavor         | `dev` flavor         |
| ------ | ----------------- | -------------------- |
| `apk`  | `assembleRelease` | `assembleDevRelease` |
| `aab`  | `bundleRelease`   | `bundleDevRelease`   |

When a module is specified, the task receives a module prefix, such as `:androidApp:assembleDevRelease`.

## Build Arguments

On the CLI, `--build-flavor` sets the flavor, and string arguments can be passed through `--flutter-build-args` (for example `module=app,profile`). JSON object arguments such as `gradle-property` require the package action's `build-args`:

```yaml
- name: Package Android APK
  uses: fastforge/package
  with:
    platform: android
    target: apk
    output: artifacts/
    build-args: '{"flavor":"dev","module":"app","gradle-property":{"versionCode":"42"}}'
```

The builder recognizes these arguments:

| Argument          | Description                                         |
| ----------------- | --------------------------------------------------- |
| `flavor`          | Android product flavor                              |
| `profile`         | Use Profile when this key exists; otherwise Release |
| `module`          | Gradle module name (task prefix only)               |
| `gradle-property` | JSON object converted to `-Pkey=value`              |
| `system-property` | JSON object converted to `-Dkey=value`              |

`build-args` must be a JSON object string.

## Artifact Locations

| Target | Default search location                                                  |
| ------ | ------------------------------------------------------------------------ |
| APK    | `app/build/outputs/apk/<mode>/` or `app/build/outputs/apk/<flavor>/<mode>/` |
| AAB    | `app/build/outputs/bundle/<mode>/` or `app/build/outputs/bundle/<flavor><Mode>/` |

If the build command succeeds but no file with the expected extension is found, Fastforge treats the build as failed.

## Limitations

- Artifact search paths are fixed to the `app/` module. When `module` names a different module, the Gradle task runs but no artifact is found, so the build fails.
- After building, Fastforge reads `applicationId`, `versionName`, and `versionCode` from `app/build.gradle.kts` for the artifact name. Projects that only have a Groovy `app/build.gradle` fail at this step.
- Channel and flavor are not included in the artifact name.

## Multiplatform Builder

The build module also contains builders for Android APK/AAB, desktop distributions for the current host, and iOS XCFramework. They are not connected to `fastforge build`, `fastforge package`, or a built-in workflow action, so this page does not provide directly runnable Fastforge commands for them.
