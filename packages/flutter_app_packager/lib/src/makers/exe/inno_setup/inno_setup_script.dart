import 'dart:convert';
import 'dart:io';

import 'package:flutter_app_packager/src/makers/exe/make_exe_config.dart';
import 'package:liquid_engine/liquid_engine.dart';
import 'package:path/path.dart' as path;

const String _template = """
[Setup]
AppId={{APP_ID}}
AppVersion={{APP_VERSION}}
AppName={{DISPLAY_NAME}}
AppPublisher={{PUBLISHER_NAME}}
AppPublisherURL={{PUBLISHER_URL}}
AppSupportURL={{PUBLISHER_URL}}
AppUpdatesURL={{PUBLISHER_URL}}
DefaultDirName={{INSTALL_DIR_NAME}}
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename={{OUTPUT_BASE_FILENAME}}
Compression=lzma
SolidCompression=yes
SetupIconFile={{SETUP_ICON_FILE}}
WizardStyle=modern
PrivilegesRequired={{PRIVILEGES_REQUIRED}}
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
{% for locale in LOCALES %}
{% if locale == 'en' %}Name: "english"; MessagesFile: "compiler:Default.isl"{% endif %}
{% if locale == 'hy' %}Name: "armenian"; MessagesFile: "compiler:Languages\\Armenian.isl"{% endif %}
{% if locale == 'bg' %}Name: "bulgarian"; MessagesFile: "compiler:Languages\\Bulgarian.isl"{% endif %}
{% if locale == 'ca' %}Name: "catalan"; MessagesFile: "compiler:Languages\\Catalan.isl"{% endif %}
{% if locale == 'zh' %}Name: "chinesesimplified"; MessagesFile: "compiler:Languages\\ChineseSimplified.isl"{% endif %}
{% if locale == 'co' %}Name: "corsican"; MessagesFile: "compiler:Languages\\Corsican.isl"{% endif %}
{% if locale == 'cs' %}Name: "czech"; MessagesFile: "compiler:Languages\\Czech.isl"{% endif %}
{% if locale == 'da' %}Name: "danish"; MessagesFile: "compiler:Languages\\Danish.isl"{% endif %}
{% if locale == 'nl' %}Name: "dutch"; MessagesFile: "compiler:Languages\\Dutch.isl"{% endif %}
{% if locale == 'fi' %}Name: "finnish"; MessagesFile: "compiler:Languages\\Finnish.isl"{% endif %}
{% if locale == 'fr' %}Name: "french"; MessagesFile: "compiler:Languages\\French.isl"{% endif %}
{% if locale == 'de' %}Name: "german"; MessagesFile: "compiler:Languages\\German.isl"{% endif %}
{% if locale == 'he' %}Name: "hebrew"; MessagesFile: "compiler:Languages\\Hebrew.isl"{% endif %}
{% if locale == 'is' %}Name: "icelandic"; MessagesFile: "compiler:Languages\\Icelandic.isl"{% endif %}
{% if locale == 'it' %}Name: "italian"; MessagesFile: "compiler:Languages\\Italian.isl"{% endif %}
{% if locale == 'ja' %}Name: "japanese"; MessagesFile: "compiler:Languages\\Japanese.isl"{% endif %}
{% if locale == 'no' %}Name: "norwegian"; MessagesFile: "compiler:Languages\\Norwegian.isl"{% endif %}
{% if locale == 'pl' %}Name: "polish"; MessagesFile: "compiler:Languages\\Polish.isl"{% endif %}
{% if locale == 'pt' %}Name: "portuguese"; MessagesFile: "compiler:Languages\\Portuguese.isl"{% endif %}
{% if locale == 'ru' %}Name: "russian"; MessagesFile: "compiler:Languages\\Russian.isl"{% endif %}
{% if locale == 'sk' %}Name: "slovak"; MessagesFile: "compiler:Languages\\Slovak.isl"{% endif %}
{% if locale == 'sl' %}Name: "slovenian"; MessagesFile: "compiler:Languages\\Slovenian.isl"{% endif %}
{% if locale == 'es' %}Name: "spanish"; MessagesFile: "compiler:Languages\\Spanish.isl"{% endif %}
{% if locale == 'tr' %}Name: "turkish"; MessagesFile: "compiler:Languages\\Turkish.isl"{% endif %}
{% if locale == 'uk' %}Name: "ukrainian"; MessagesFile: "compiler:Languages\\Ukrainian.isl"{% endif %}
{% endfor %}

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: {% if CREATE_DESKTOP_ICON != true %}unchecked{% else %}checkedonce{% endif %}
Name: "launchAtStartup"; Description: "{cm:AutoStartProgram,{{DISPLAY_NAME}}}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: {% if LAUNCH_AT_STARTUP != true %}unchecked{% else %}checkedonce{% endif %}
[Files]
Source: "{{SOURCE_DIR}}\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"
Name: "{autodesktop}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"; Tasks: desktopicon
Name: "{userstartup}\\{{DISPLAY_NAME}}"; Filename: "{app}\\{{EXECUTABLE_NAME}}"; WorkingDir: "{app}"; Tasks: launchAtStartup
[Run]
Filename: "{app}\\{{EXECUTABLE_NAME}}"; Description: "{cm:LaunchProgram,{{DISPLAY_NAME}}}"; Flags: {% if PRIVILEGES_REQUIRED == 'admin' %}runascurrentuser{% endif %} nowait postinstall skipifsilent
""";

class InnoSetupScript {
  InnoSetupScript({
    required this.makeConfig,
  });

  factory InnoSetupScript.fromMakeConfig(MakeExeConfig makeConfig) {
    return InnoSetupScript(
      makeConfig: makeConfig,
    );
  }

  final MakeExeConfig makeConfig;

  Future<File> createFile() async {
    Map<String, dynamic> variables = {
      'APP_ID': makeConfig.appId,
      'APP_NAME': makeConfig.appName,
      'APP_VERSION': makeConfig.appVersion.toString(),
      'EXECUTABLE_NAME':
          makeConfig.executableName ?? makeConfig.defaultExecutableName,
      'DISPLAY_NAME': makeConfig.displayName,
      'PUBLISHER_NAME': makeConfig.publisherName,
      'PUBLISHER_URL': makeConfig.publisherUrl,
      'CREATE_DESKTOP_ICON': makeConfig.createDesktopIcon,
      'LAUNCH_AT_STARTUP': makeConfig.launchAtStartup,
      'INSTALL_DIR_NAME':
          makeConfig.installDirName ?? makeConfig.defaultInstallDirName,
      'SOURCE_DIR': makeConfig.sourceDir,
      'OUTPUT_BASE_FILENAME': makeConfig.outputBaseFileName,
      'LOCALES': makeConfig.locales,
      'SETUP_ICON_FILE': makeConfig.setupIconFile ?? '',
      'PRIVILEGES_REQUIRED': makeConfig.privilegesRequired ?? 'none'
    }..removeWhere((key, value) => value == null);

    Context context = Context.create();
    context.variables = variables;

    String scriptTemplate = _template;
    if (makeConfig.scriptTemplate != null) {
      File scriptTemplateFile = File(path.join(
        'windows/packaging/exe/',
        makeConfig.scriptTemplate!,
      ));
      scriptTemplate = scriptTemplateFile.readAsStringSync();
    }

    Template template = Template.parse(
      context,
      Source.fromString(scriptTemplate),
    );

    String content = '\uFEFF${await template.render(context)}';
    File file = File('${makeConfig.packagingDirectory.path}.iss');

    file.writeAsBytesSync(utf8.encode(content));
    return file;
  }
}
