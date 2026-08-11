# `fastforge analyze`

Reads an artifact's identity (name, identifier, version, build number) and —
for deeply analyzed formats — its tech stack, shipped libraries, size
composition, and signing state. Accepts any number of artifacts and scans
directories recursively (hidden entries skipped, symlinks not followed; a
`.app` bundle counts as an artifact, not a directory).

## Formats and dependencies

| Format | Host | Dependencies |
| --- | --- | --- |
| APK | any | `aapt2` under `ANDROID_HOME`; optionally `apksigner` |
| AAB | any | `aapt2`, or `BUNDLETOOL=/path/to/bundletool.jar` |
| IPA | any | none |
| DMG | macOS only | `hdiutil`, `diskutil`; optionally `codesign`, `spctl`, `xcrun stapler` |
| `.app` | macOS only | `Info.plist`; optionally `codesign`, `spctl`, `xcrun stapler` |

## Usage

```bash
fastforge analyze dist/app-release.apk               # JSON to stdout
fastforge analyze dist/app.ipa --output analysis.json
fastforge analyze dist --output report.html          # directory scan, HTML report
fastforge analyze dist/android build/ios/ipa         # multiple paths
```

- `--format json|html` overrides the format implied by the `--output`
  extension (e.g. HTML to stdout, or JSON into a `.html` path).
- Single named artifact → that artifact's payload directly. Multiple artifacts
  or directory scans → wrapper `{generatedAt, artifactCount, artifacts[],
  failures[]}`; a bad file found while scanning lands in `failures` instead of
  failing the run, but a path named explicitly must analyze successfully.
- Exit status is nonzero for unsupported extensions, missing tools, or
  unparsable artifacts — safe to gate CI on.

## Common identity fields (all formats)

`platform`, `format`, `identifier`, `name`, `version`, `buildNumber`,
`fileName`, `sizeBytes`, `sha256`. Keys are omitted (not null) when the
artifact lacks the metadata. `buildNumber` is a string for Apple artifacts
(CFBundleVersion is not always numeric), an integer for Android version codes.

## `techStack` (all deeply analyzed formats)

- `runtime`: `flutter`, `electron`, `react-native`, `unity`, `cordova`,
  `dotnet`, `qt`, `java`, or `native`, plus a `<runtime>` detail object
  (engine revision, build mode, AOT, plugins, JS engine, …).
- `languages`, `uiToolkits` (SwiftUI/AppKit/UIKit; Jetpack Compose/AppCompat).
- `toolchain` / `buildTools`: deployment target, SDK, compiler/Gradle stamps.
- `libraries` / `dependencies` (Android Maven coordinates),
  `nativeLibraries` (`.so` files), `thirdPartySdks` (recognized SDKs with
  their purpose), and Apple link tables (`systemFrameworks`,
  `embeddedFrameworks`, `systemLibraries`, `privateFrameworks` — from the main
  executable's Mach-O load commands).

## Per-format highlights

- **macOS `.app`**: `architectures`/`universal`, `sizeBreakdown` +
  `largestFiles`, `buildInfo`, embedded `components`, `codeSignature`
  (signing type, team, hardened runtime, entitlements, notarization,
  Gatekeeper), `provisioningProfile`, `urlSchemes`, `documentTypes`,
  `privacyUsageDescriptions`, `category`, `minOSVersion`, `localizations`,
  `sandboxed`.
- **DMG**: the image's own `codeSignature`, `diskImage` (format, compression,
  checksum, partitions), `volume` (name, `/Applications` symlink, window
  layout), and the primary bundle's full analysis nested under `app` (others
  summarized under `apps`). Encrypted images are rejected.
- **IPA**: read straight from the archive, no unpacking, no macOS needed.
  `deviceFamilies`, `minOSVersion`, `buildInfo`, `components` (extensions,
  watch apps), `capabilities`, `provisioningProfile` (with
  `distributionType`: `development` / `ad-hoc` / `enterprise` / `app-store`),
  `contents`, `codeSignature`.
- **APK/AAB**: `abis`, `manifest` (min/target/compile SDK, permissions,
  locales…), `contents` (dex count, size per directory; `sizeBreakdown` uses
  compressed sizes since that is the download cost), `signature` (APK:
  verified schemes via `apksigner`; AAB: JAR-signed or not), and AAB-only
  `modules` (base + dynamic features) plus the resolved dependency graph
  (richer than APK version markers).

## HTML report

`--output report.html` writes a single self-contained file (no external
assets). It opens with distributions by runtime, signing state, and size;
clicking bars stacks filters; rows expand to identity, tech stack, size,
signing, and raw JSON. Failures are listed at the end. Needs JavaScript — use
JSON output for programmatic reads.

## Notes

- macOS signature inspection needs `codesign`; Gatekeeper (`spctl`) and
  notarization (`stapler`) checks run only on signed artifacts and may reach
  the network. Each external tool call is capped at 30s; a missing tool
  silently omits its section.
