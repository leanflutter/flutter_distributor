# Building

English | [简体中文](../zh-Hans/building.md)

Building invokes the build system used by the project and locates its raw artifacts. Build results can be used directly for testing and analysis, or passed to a [packager](packagers/README.md) to produce a distributable format.

## Building vs. Packaging

| Operation | Primary responsibility                               | Common outputs                                                    |
| --------- | ---------------------------------------------------- | ----------------------------------------------------------------- |
| Build     | Compile the project and locate raw artifacts         | APK, AAB, IPA, `.app`, desktop bundle, web directory, HAP/APP     |
| Package   | Invoke a builder, then prepare a distribution format | APK, AAB, IPA, DMG, PKG, ZIP, EXE, MSIX, AppImage, DEB, RPM, etc. |

If you only need the final distributable file, use `fastforge package` directly. The packaging process invokes the appropriate builder automatically, so you do not need to run `fastforge build` first.

## Current Command Boundaries

Fastforge includes Gradle, Xcode, Flutter, and Custom builders, but they are exposed through the CLI in different ways:

| Builder              | Current entry point                             | Status                             |
| -------------------- | ----------------------------------------------- | ---------------------------------- |
| Flutter Builder      | `fastforge build`, `fastforge package`, action  | All Flutter platforms connected    |
| Gradle Android       | `fastforge package`, `fastforge/package` action | APK and AAB are connected          |
| Xcode iOS / macOS    | `fastforge/package` action, `fastforge package` | IPA and macOS `.app` are connected |
| Gradle Multiplatform | No top-level command                            | Build module only                  |
| Custom Builder       | No top-level command                            | Build module only                  |

> [!IMPORTANT]
> `fastforge build` always uses Flutter Builder and requires a Flutter project. Gradle and Xcode Builder are reached only through `fastforge package` or the `fastforge/package` action; see the [builder overview](builders/README.md).

## Run a Build Separately

```bash
fastforge build [--platform <platform>] [--target <target>]
```

For example:

```bash
fastforge build --platform android --target apk
fastforge build --platform web
fastforge build --target ipa --build-export-method app-store
```

When `--platform` is omitted, it is inferred from `--target` (for example `apk` → `android`, `dmg` → `macos`). Without a target, or with an ambiguous one such as `zip`, Fastforge uses the platform directories in the project and what the current host can build, preferring the host platform; if that is still ambiguous, pass `--platform`. Some platforms require `--target` (`apk`/`aab` for Android, `hap`/`app` for OpenHarmony). `build` does not run `flutter clean` unless `--clean` is given.

See [Flutter Builder](builders/flutter.md) for supported platforms, targets, build arguments, artifact locations, and host restrictions.

## Build Results

After a successful build, `fastforge build` writes JSON to standard output containing:

- `config`: build mode, flavor, and effective arguments
- `outputDirectory`: build output directory
- `outputFiles`: detected artifact paths (empty for directory builds such as Windows, Linux, and Web)
- `duration`: build duration in milliseconds

If the build command succeeds but no artifact is found in the expected directory (or, for directory builds, the output directory does not exist), Fastforge still reports a failure. This prevents later packaging or publishing steps from using an empty directory.

## Build During Packaging

Gradle and Xcode Builder are used through `package` in projects without `pubspec.yaml`:

```bash
fastforge package --platform android --targets apk
```

Xcode builds require arguments such as `project` and `scheme`. The CLI has no dedicated flags for them; pass them through a workflow action's `build-args` (recommended), or as string values through `--flutter-build-args project=...,scheme=...`. See [Xcode Builder](builders/xcode.md) for a complete example.

## Next Steps

- Review builders and their integration status: [Builder Overview](builders/README.md)
- Produce a distributable artifact: [Packaging](packaging.md)
- Analyze a build artifact: [App Package Analysis](tools/analyze.md)
- Combine building, packaging, and publishing: [Local Workflows](workflows.md)
