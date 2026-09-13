# Windows

English | [简体中文](../../zh-Hans/packagers/windows.md)

Fastforge packages Flutter Windows applications as [EXE](#exe), [MSIX](#msix), [ZIP, or a direct copy](#zip-and-direct).

## Current Status

| Build system    | `package` status                              |
| --------------- | --------------------------------------------- |
| Flutter Builder | EXE, MSIX, ZIP, and direct through CLI/action |

Windows packaging requires a Flutter project (`pubspec.yaml`). The build runs only on a Windows host; on other hosts `fastforge package` skips the target with a warning. The packagers use the runner directory `build/windows/<arch>/runner/<Mode>/` (`build/windows/runner/<Mode>/` on Flutter versions before 3.15), and artifacts are written to `dist/<version>/`.

```bash
fastforge package --targets exe,zip
```

## EXE

EXE creates an installer with Inno Setup. It is the only format marked as an installer, so the default artifact name ends in `-setup.exe`.

Requirements: Inno Setup 6. Fastforge runs `ISCC.exe` from the directory in `INNO_SETUP_PATH` (from the environment or `distribute_options.yaml` variables), or from `C:\Program Files (x86)\Inno Setup 6` by default.

Optional configuration: `windows/packaging/exe/make_config.yaml`, with keys such as `app_id`, `publisher_name`, `publisher_url`, `display_name`, `executable_name`, `install_dir_name`, `setup_icon_file`, `locales`, `create_desktop_icon`, `launch_at_startup`, `privileges_required`, and `script_template`.

## MSIX

MSIX reads optional `windows/packaging/msix/make_config.yaml`, using the same keys as the `msix` pub package, such as `display_name`, `publisher_display_name`, `identity_name`, `msix_version`, `logo_path`, `capabilities`, `certificate_path`, `certificate_password`, `publisher`, and `signtool_options`.

- If the project depends on the `msix` package, Fastforge runs `dart run msix:create` with those settings.
- Otherwise it uses the Windows SDK tools `makeappx` and `signtool`, merging `msix_config` from `pubspec.yaml` under `make_config.yaml`. Without `certificate_path` or `signtool_options`, the package is left unsigned and a warning is printed.

## ZIP and direct

`zip` archives the runner directory; `direct` copies it to `dist/<version>/` without an archive. Both need no extra tools.

Return to the [packager overview](README.md).
