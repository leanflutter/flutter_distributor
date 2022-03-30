import 'dart:io';
import 'package:path/path.dart' as p;

import 'make_exe_config.dart';

String _issFileTemplate = """
#define MyAppId "{{appId}}"
#define MyAppName "{{appName}}"
#define MyAppVersion "{{appVersion}}"
#define MyAppPublisher "{{appPublisher}}"
#define MyAppURL "{{appPublisherUrl}}"
#define MyAppExeName "{{appExeName}}"

#define MyAppPackagingDir "{{appPackagingDir}}"
#define MyAppOutputBaseFilename "{{appOutputBaseFilename}}"
#define DeskTopIconChecked "{{deskTopIconChecked}}"


[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\\{#MyAppName}
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=.
OutputBaseFilename={#MyAppOutputBaseFilename}
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
;Name: "chinesesimplified"; MessagesFile: "compiler:Languages\\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";{#DeskTopIconChecked}

[Files]
Source: "{#MyAppPackagingDir}\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\\{#MyAppName}"; Filename: "{app}\\{#MyAppExeName}"
Name: "{autodesktop}\\{#MyAppName}"; Filename: "{app}\\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
""";

Future<File> createSetupScriptFile(MakeExeConfig makeConfig) async {
  File exeFile = makeConfig.packagingDirectory
      .listSync()
      .where((e) => e.path.endsWith('.exe'))
      .map((e) => File(e.path))
      .first;

  var variables = {
    'appId': makeConfig.appId,
    'appName': makeConfig.appName,
    'appVersion': makeConfig.appVersion.toString(),
    'appPublisher': makeConfig.appPublisher ?? '',
    'appPublisherUrl': makeConfig.appPublisherUrl ?? '',
    'appExeName': makeConfig.appExeFileName ?? p.basename(exeFile.path),
    'appPackagingDir': p.basename(makeConfig.packagingDirectory.path),
    'appOutputBaseFilename':
        p.basename(makeConfig.outputFile.path).replaceAll('.exe', ''),
    'deskTopIconChecked':makeConfig.defaultDesktopIconCkecked ? "" : " Flags: unchecked"
  };

  String content = _issFileTemplate;
  for (var key in variables.keys) {
    content = content.replaceAll('{{$key}}', variables[key].toString());
  }

  File file = File('${makeConfig.packagingDirectory.path}.iss');
  await file.writeAsString(content);
  return file;
}
