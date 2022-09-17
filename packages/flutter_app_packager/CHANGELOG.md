## 0.2.6

* [maker-zip] remove packagingDirectory after make

## 0.2.5

* Use `shell_executor` to execute commands
* Merge app makers into this package
* [maker-zip] without using the 7zip command

## 0.2.4

* [dmg maker] Support `code-sign` configuration item.
* [exe maker] Support use custom inno setup `script_template`. #69
* [exe maker] Support use custom installDirName. #67
* [exe maker] Add installer `setupIconFile`, `privilegesRequired` options (#79)
* Downgrade pubspec_parse to 1.1.0
* [exe maker] Set to default 64-bit mode #81

## 0.2.1

* `artifactName` adds `build_name` & `build_number` variables #66

## 0.2.0

* Fix apk, ipa makers copy wrong files #55

## 0.1.9

* [exe maker] MakeExeConfig Add `executable_name` field
* [exe maker] MakeExeConfig Add `display_name` field
* [exe maker] MakeExeConfig Add `create_desktop_icon` field
* [exe maker] MakeExeConfig Add `install_dir_name` field
* [exe maker] MakeExeConfig Add `locales` field
* [exe maker] Support chinese #57 #58

## 0.1.8

* [aab maker] support flavor arg #46

## 0.1.6

* `PowerShell` support.

## 0.1.4

* #22 zip maker supports web platform.

## 0.1.0

* First release.
