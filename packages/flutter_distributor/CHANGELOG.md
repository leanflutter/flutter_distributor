## 0.2.5
* Fix an incorrectly worded message

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
