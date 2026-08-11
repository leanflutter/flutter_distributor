# iOS packaging (IPA)

All iOS operations require macOS with Xcode command-line tools.

## Native Xcode projects — package action only

The top-level CLI cannot pass `project`/`scheme`, so native iOS packaging runs
through a workflow `fastforge/package` action:

```yaml
- name: Package IPA
  uses: fastforge/package
  with:
    platform: ios
    target: ipa
    output: artifacts/
    build-args: '{"project":"ios/MyApp.xcodeproj","scheme":"MyApp","export-options-plist":"ios/ExportOptions.plist"}'
```

The build has two stages: `xcodebuild archive` → `.xcarchive`, then
`xcodebuild -exportArchive` → IPA.

| `build-args` field | Required | Meaning |
| --- | :-: | --- |
| `project` | yes | Path to `.xcodeproj` |
| `scheme` | yes | Xcode scheme |
| `configuration` | no | Defaults to `Release` |
| `export-options-plist` | one of | Path to an ExportOptions plist |
| `export-method` | one of | Generates a temporary export config when no plist given |
| `archive-path` | no | Defaults to `ios/build/Runner.xcarchive` |
| `export-path` | no | Defaults to `ios/build/ipa` |
| `derived-data-path` | no | DerivedData directory |
| `xcconfig-override` | no | Extra xcconfig file |
| `extra-flags` | no | Array of extra xcodebuild arguments |

Provide at least one of `export-options-plist` / `export-method`.

## Flutter projects — `fastforge build`

The iOS packager is not connected for Flutter projects (`package` builds then
fails). Build the IPA directly; export configuration is required:

```bash
fastforge build --platform ios --target ipa \
  --build-export-options-plist ios/ExportOptions.plist
# or
fastforge build --platform ios --target ipa \
  --build-export-method app-store
```

Other Flutter build options (flavor, dart-define, obfuscation…) are listed in
[android.md](android.md) and apply here too. Artifacts land in
`build/ios/ipa/`.

## After the IPA exists

- Upload to App Store Connect: `fastforge publish --path dist/MyApp.ipa
  --target appstore` (fastforge-publish skill), or `fastforge appstore build
  upload --wait` when you want processing status and review flow
  (fastforge-stores skill).
- Ad-hoc distribution (fir.im, Firebase App Distribution): fastforge-publish
  skill.
- Inspect device families, provisioning, entitlements: `fastforge analyze
  dist/MyApp.ipa` — works on any host, no unpacking.
