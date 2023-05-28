## 0.3.3

* [apk-builer] fix apk not found 

## 0.3.2

* Update dart sdk version to ">=2.16.0 <4.0.0"
* feat: compress macOS app with 7zip
* [dmg-maker] Rename `backgroundColor` to `background-color` in `MakeDmgConfig`
* [dmg-maker] fix: fix make_dmg_config lost <window> specification (#120)
* [deb-maker] Fixes #117 install and uninstall errors (#121)
* fix(docs): fix exe make_config.yaml example error
* chore: Optimize msix maker

## 0.3.1

* Add `direct` maker
* [rpm] fix lib/*.so rpath before packaging (#110)
* feat:fix appdmg “icon-size” Specification。 (#113)
* Add `firebase-hosting` publisher.
* Add `vercel` publisher.
* Modify the `publish` method to accept `FileSystemEntity` instead of just `File`
* Add the `workingDirectory` parameter to the `DefaultShellExecutor` and related classes.
* Bump `shell_executor` to 0.1.2.

## 0.3.0

* bump flutter to 3.7
* [exe] add template support for all innosetup 6.x default languages (#102)
* Improve command usability (help texts, null checks, misc) (#106)
* apk & app maker support profile mode.
* flutter_distributor command add version-check flag
* [AppImage] Use appimagetool to bundle AppImage (#109)
* Refactor flutter_distributor

## 0.2.8

* fix iOS builder adds export build argument check error

## 0.2.7

* Feat: Linux RPM packaging support (#101)
* iOS builder adds export build argument check

## 0.2.6

* [maker-zip] remove packagingDirectory after make

## 0.2.5

* Use `shell_executor` to execute commands
* Fix an incorrectly worded message
* Optimize output messages in console
* Support linux arm64
* [maker-zip] without using the 7zip command
* [publisher-pgyer] Upgrade to v2 Api #91 #92

## 0.2.4

* [dmg maker] Support `code-sign` configuration item.
* [exe maker] Support use custom inno setup `script_template`. #69
* [exe maker] Support use custom installDirName. #67
* [exe maker] Add installer `setupIconFile`, `privilegesRequired` options (#79)
* [exe maker] Set to default 64-bit mode #81

## 0.2.2

* Support custom `artifact_name` & `channel`.
* fix build_args map entries value may null #64
* Add dart-define `FLUTTER_BUILD_NAME` and `FLUTTER_BUILD_NUMBER` when building #65
* `artifactName` adds `build_name` & `build_number` variables #66

## 0.2.0

* Add `appcenter` publisher. #13
* Fix apk, ipa makers copy wrong files #55

## 0.1.9

* [exe maker] MakeExeConfig Add `executable_name` field
* [exe maker] MakeExeConfig Add `display_name` field
* [exe maker] MakeExeConfig Add `create_desktop_icon` field
* [exe maker] MakeExeConfig Add `install_dir_name` field
* [exe maker] MakeExeConfig Add `locales` field
* [exe maker] Support chinese #57 #58
* Add msix maker

## 0.1.8

* [aab maker] support flavor arg #46
* Add `appstore` publisher. #45

## 0.1.7

* Change parameter `cleanOnceBeforeBuild` to `cleanBeforeBuild`
* Changed to only clean once before build #41

## 0.1.6

* `PowerShell` support.
* Fix the problem of broken files after uploading.

## 0.1.5

* Add `firebase` publisher.
* Add `github` publisher.

## 0.1.4

* Add `--version` flag.
* Add `qiniu` publisher.
* #21 Add `--jobs` and `--skip-jobs` option to `release` command.
* #22 `zip` maker supports web platform.

## 0.1.3

* #12 Add `--skip-clean` flag to `package` and `release` commands.
* Optimize `exe` maker (Using `Inno Setup`).

## 0.1.2

* `dart-define` arg support multi values.
* Remove `console_bars` and Replace to `ProgressBar`.

## 0.1.0

* First release.
