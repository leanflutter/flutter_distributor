# Windows / Linux / Web / OpenHarmony / custom packaging

All of these route through Flutter Builder (`pubspec.yaml` projects only; a
project without `pubspec.yaml` errors for these platforms) and are available
from the CLI and the `fastforge/package` action. Host restrictions: Windows
builds run on Windows, Linux builds on Linux; web and ohos builds run on any
host with their toolchain. On the wrong host the target is skipped with a
warning (exit 0).

## Windows — `exe`, `msix`, `zip`, `direct`

```bash
fastforge package --targets exe,zip      # --platform windows inferred from exe
```

The build output directory is `build/windows/<arch>/runner/<Mode>/`
(`build/windows/runner/<Mode>/` on Flutter < 3.15).

- **EXE** — Inno Setup installer. Needs Inno Setup 6: `ISCC.exe` from
  `INNO_SETUP_PATH` (env or `distribute_options.yaml` variables) or
  `C:\Program Files (x86)\Inno Setup 6`. Reads optional
  `windows/packaging/exe/make_config.yaml` (`app_id`, `publisher_name`,
  `publisher_url`, `display_name`, `executable_name`, `install_dir_name`,
  `setup_icon_file`, `locales`, `create_desktop_icon`, `launch_at_startup`,
  `privileges_required`, `script_template`, …).
- **MSIX** — reads optional `windows/packaging/msix/make_config.yaml` (same
  keys as the `msix` pub package: `display_name`, `publisher_display_name`,
  `identity_name`, `msix_version`, `logo_path`, `capabilities`,
  `certificate_path`, `certificate_password`, `publisher`, …).
  - If the project depends on `msix`, packaging runs `dart run msix:create`
    with those keys.
  - Otherwise a native fallback uses Windows SDK `makeappx` / `signtool`,
    merging `pubspec.yaml` `msix_config:` under make_config. Without
    `certificate_path` (or `signtool_options`) the package is left
    **unsigned** with a warning.
- `exe` is the only target treated as an installer in artifact naming
  (`…-setup.exe` with the default template).
- `zip` / `direct` archive or copy the runner directory.

## Linux — `appimage`, `deb`, `rpm`, `pacman`, `zip`, `direct`

```bash
fastforge package --targets deb,appimage
```

- Each installer format reads an optional
  `linux/packaging/<format>/make_config.yaml` (Dart CLI schema: e.g.
  `display_name`, `package_name`, `maintainer`, `dependencies`, `icon`,
  `metainfo`, `categories`, `keywords`, `generic_name`, `startup_notify`; rpm
  adds `summary`, `license`, `requires`, …; appimage adds `include`,
  `actions`).
- The binary name is read from `BINARY_NAME` in `linux/CMakeLists.txt`
  (falls back to the pubspec name).
- Build output: `build/linux/<x64|arm64>/<mode>/bundle/`.
- Required host tools per format:

  | Format | Tools |
  | --- | --- |
  | `deb` | `dpkg-deb` |
  | `rpm` | `rpmbuild`, `patchelf` |
  | `pacman` | `bsdtar`, `xz` |
  | `appimage` | `appimagetool`, `ldd` (+ `locate` when `include` is set) |
  | `zip`, `direct` | none (built in) |

## Web — `zip`, `direct`

```bash
fastforge package --platform web --targets zip
```

`zip` archives the contents of `build/web/`; `direct` copies the directory
as-is to `dist/<version>/<name>` (no extension). Publish the result with
`firebase-hosting`, `vercel`, or S3 (fastforge-publish skill).

## OpenHarmony — `hap`, `app`

```bash
fastforge package --platform ohos --targets hap
```

Requires a Flutter SDK with OpenHarmony support (`flutter build hap|app`).
The signed artifact is looked up as `*-<flavor>-signed.hap` in
`ohos/entry/build/<flavor>/outputs/<flavor>/` (HAP) or `*-<flavor>-signed.app`
in `ohos/build/outputs/<flavor>/` (APP); `<flavor>` defaults to `default`.

## `custom` — script-driven packaging

For formats fastforge doesn't ship (Flutter projects on any platform, and
native macOS; native iOS/Android reject it). The config file is **required**:
`<platform>/packaging/custom/make_config.yaml`:

```yaml
script: ./scripts/package.sh   # required
# Omit or leave empty to produce a directory artifact instead of a file.
output_extension: tar.gz
```

```bash
fastforge package --platform linux --targets custom
```

`custom` carries no platform hint, so pass `--platform` unless the project
layout and host make it unambiguous. The script runs via `sh -c` (`cmd /c` on
Windows) and receives: `APP_NAME`, `APP_VERSION`, `BUILD_NAME`,
`BUILD_NUMBER` (when present), `BUILD_MODE`, `FLAVOR` (when present),
`CHANNEL` (when present), `BUILD_OUTPUT_DIRECTORY`, `OUTPUT_DIRECTORY`, and
`OUTPUT_ARTIFACT_PATH` (where it must place the result — a file, or a
directory when `output_extension` is empty). Nonzero exit, or nothing at
`OUTPUT_ARTIFACT_PATH`, fails the packaging run.
