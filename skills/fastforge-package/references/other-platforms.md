# Windows / Linux / Web / OpenHarmony / custom packaging

All of these route through Flutter Builder (`pubspec.yaml` projects) and are
available from the CLI and the `fastforge/package` action. Host restrictions:
Windows formats build on Windows, Linux formats on Linux; web and ohos follow
their toolchains.

## Windows — `exe`, `msix`, `zip`, `direct`

```bash
fastforge package --targets exe,zip      # --platform windows inferred from exe
```

- **EXE** (Inno Setup installer) and **MSIX** read an optional
  `windows/packaging/exe/make_config.yaml` /
  `windows/packaging/msix/make_config.yaml` (same schema as the Dart CLI's
  make_config). MSIX signing: PFX certificate path/password and publisher
  (`CN=…`) come from the make_config or explicit overrides.
- `exe` is the only target treated as an installer in artifact naming
  (`…-setup.exe` with the default template).

## Linux — `appimage`, `deb`, `rpm`, `pacman`, `zip`, `direct`

```bash
fastforge package --targets deb,appimage
```

- Each format reads an optional `linux/packaging/<format>/make_config.yaml`
  (same schema as the Dart CLI: metadata, dependencies, desktop entry…).
- The binary name is read from `BINARY_NAME` in `linux/CMakeLists.txt`.
- The respective system tools must be installed (e.g. `dpkg-deb`, `rpmbuild`,
  `makepkg`, appimagetool).

## Web — `zip`, `direct`

```bash
fastforge package --platform web --targets zip
```

`zip` archives `build/web/`; `direct` copies the directory as-is. Publish the
result with `firebase-hosting`, `vercel`, or S3 (fastforge-publish skill).

## OpenHarmony — `hap`, `app`

```bash
fastforge package --platform ohos --targets hap
```

Requires the OpenHarmony toolchain. Raw artifacts come from
`ohos/entry/build/<flavor>/outputs/<flavor>/` (HAP) and
`ohos/build/outputs/<flavor>/` (APP).

## `custom` — script-driven packaging (any platform)

For formats fastforge doesn't ship. Configure
`<platform>/packaging/custom/make_config.yaml`:

```yaml
script: ./scripts/package.sh
# Omit or leave empty to produce a directory artifact instead of a file.
output_extension: tar.gz
```

```bash
fastforge package --platform linux --targets custom
```

The script receives: `APP_NAME`, `APP_VERSION`, `BUILD_NAME`, `BUILD_NUMBER`
(when present), `BUILD_MODE`, `FLAVOR` (when present), `CHANNEL` (when
present), `BUILD_OUTPUT_DIRECTORY`, `OUTPUT_DIRECTORY`, and
`OUTPUT_ARTIFACT_PATH` (where it must place the result). Nonzero exit fails
the packaging run.
