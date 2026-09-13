# iOS packaging (IPA)

Building and packaging require macOS with Xcode command-line tools.

## Native Xcode projects (no `pubspec.yaml`)

The CLI has no dedicated flags for `project`/`scheme`, so the recommended path
is a workflow `fastforge/package` action:

```yaml
- name: Package IPA
  uses: fastforge/package
  with:
    platform: ios
    target: ipa
    output: artifacts/
    build-args: '{"project":"ios/MyApp.xcodeproj","scheme":"MyApp","export-options-plist":"ios/ExportOptions.plist"}'
```

`fastforge package` routes native projects too, so string arguments can also
be passed as `--flutter-build-args project=ios/MyApp.xcodeproj,scheme=MyApp,export-method=app-store`
(array arguments such as `extra-flags` need the action).

The build has two stages: `xcodebuild archive` → `.xcarchive`, then
`xcodebuild -exportArchive` → IPA (newest `*.ipa` in `export-path`).

| `build-args` field | Required | Meaning |
| --- | :-: | --- |
| `project` | yes | Path to `.xcodeproj` (passed as `-project`; workspaces are not supported) |
| `scheme` | yes | Xcode scheme |
| `configuration` | no | Defaults to `Release` |
| `export-options-plist` | one of | Path to an ExportOptions plist (wins over `export-method`) |
| `export-method` | one of | Generates a temporary plist with `method` + automatic signing |
| `archive-path` | no | Defaults to `ios/build/Runner.xcarchive` |
| `export-path` | no | Defaults to `ios/build/ipa` |
| `derived-data-path` | no | DerivedData directory (archive step) |
| `xcconfig-override` | no | Extra xcconfig file (archive step) |
| `extra-flags` | no | Array of extra `xcodebuild archive` arguments |

Provide at least one of `export-options-plist` / `export-method`. Only `ipa`
is accepted for native iOS (it is checked before building). App name and
version for the artifact name come from the app's `Info.plist` (read from the
archive when `archive-path` is set explicitly, otherwise from the IPA);
channel and flavor are not used.

## Flutter projects — `fastforge package` (or `build`)

Flutter projects package IPAs end-to-end; export configuration is required:

```bash
fastforge package --targets ipa \
  --build-export-options-plist ios/ExportOptions.plist
# or: --flutter-build-args export-method=app-store
```

`fastforge build --platform ios --target ipa` produces the raw IPA without
the packaging stage (`--build-export-method app-store` works as the plist
alternative on the build command).

Other Flutter build options (flavor, dart-define, obfuscation…) are listed in
[android.md](android.md) and apply here too. Raw build output lands in
`build/ios/ipa/`; the packaged IPA in `dist/<version>/`.

## After the IPA exists

- Upload to App Store Connect: `fastforge publish --path dist/<version>/MyApp-….ipa
  --targets appstore` (fastforge-publish skill), or `fastforge appstore build
  upload --app <APP> <IPA> --wait` when you want processing status and review
  flow (fastforge-stores skill).
- Ad-hoc distribution (fir.im, Firebase App Distribution): fastforge-publish
  skill.
- Inspect device families, provisioning, entitlements: `fastforge analyze
  <path/to/app.ipa>` — works on any host, no unpacking.
