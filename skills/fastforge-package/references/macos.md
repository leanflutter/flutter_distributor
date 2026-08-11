# macOS packaging (DMG / PKG / ZIP)

Requires macOS with Xcode command-line tools. Fastforge builds the `.app`
(Xcode Builder or Flutter Builder, chosen from project files) and hands it to
the selected packager.

## Flutter projects — direct CLI

```bash
fastforge package --platform macos --target dmg
fastforge package --platform macos --target pkg
fastforge package --platform macos --target zip
```

This is currently the *only* platform where a Flutter project can use
`fastforge package` end-to-end. Flavors, dart-defines, and custom entry
points use the same `--build-*` options listed in [android.md](android.md);
artifacts are written to `dist/`.

## Native Xcode projects — package action only

Pass the project through `build-args` in a workflow:

```yaml
- name: Package macOS app
  uses: fastforge/package
  with:
    platform: macos
    target: zip
    output: artifacts/
    build-args: '{"project":"macos/MyApp.xcodeproj","scheme":"MyApp","configuration":"Release","product-name":"MyApp"}'
```

| `build-args` field | Required | Meaning |
| --- | :-: | --- |
| `project` | yes | Path to `.xcodeproj` |
| `scheme` | yes | Xcode scheme |
| `configuration` | no | Defaults to `Release` |
| `derived-data-path` | no | DerivedData directory |
| `product-name` | no | `.app` name to match in build products |
| `sdk` | no | Passed to `xcodebuild -sdk` |
| `xcconfig-override` | no | Extra xcconfig file |
| `extra-flags` | no | Array of extra xcodebuild arguments |

## Format notes

- **DMG** — uses the built-in DMG maker; the old global `appdmg` Node tool is
  no longer required.
- **PKG** — reads `macos/packaging/pkg/make_config.yaml` and **fails if the
  file is missing or invalid**; create it before the first PKG run. A PKG can
  be uploaded to the Mac App Store: `fastforge publish --path dist/MyApp.pkg
  --target appstore`.
- **ZIP** — compresses the `.app`; ideal for GitHub Releases, S3, or a
  download server via fastforge-publish.

## Signing and notarization

Run `codesign` / `notarytool` steps through the packaging hooks
(`--hook-post` on the CLI, `hook-post` on the action) — fastforge does not
sign for you. Verify the result afterwards with `fastforge analyze
dist/MyApp.dmg`, which reports signing type, notarization stapling, and
Gatekeeper state.
