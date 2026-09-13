use std::path::{Path, PathBuf};
use std::process::Command;

use fastforge_core::{AppPackager, PackageConfig, PackageError, PackageResult, Platform};
use serde::Deserialize;

use crate::fs_util::copy_dir_contents;

/// Builds a Windows `.exe` installer using Inno Setup (`iscc`), mirroring
/// Dart's `AppPackageMakerExe`.
///
/// Reads `windows/packaging/exe/make_config.yaml` when present (same schema
/// as Dart's `MakeExeConfig`); falls back to sensible defaults otherwise.
///
/// The Inno Setup script — Dart's default template or a custom
/// `script_template` — is rendered with Liquid using the same variables as
/// Dart (`APP_ID`, `APP_NAME`, `APP_VERSION`, `EXECUTABLE_NAME`,
/// `DISPLAY_NAME`, `PUBLISHER_NAME`, `PUBLISHER_URL`, `CREATE_DESKTOP_ICON`,
/// `LAUNCH_AT_STARTUP`, `INSTALL_DIR_NAME`, `SOURCE_DIR`,
/// `OUTPUT_BASE_FILENAME`, `LOCALES`, `SETUP_ICON_FILE`,
/// `PRIVILEGES_REQUIRED`, `ARCHITECTURES_ALLOWED`,
/// `ARCHITECTURES_INSTALL_IN_64BIT_MODE`), so a template copied from the Dart
/// implementation renders identically. Undefined variables render empty.
///
/// Requires Inno Setup (`iscc`) to be on `%PATH%`, in the default install
/// location, or pointed to by the `INNO_SETUP_PATH` variable (process
/// environment or `distribute_options.yaml` variables; Windows only).
pub struct WindowsExePackager;

/// Dart's default Inno Setup script template (`inno_setup_script.dart`),
/// verbatim.
const DEFAULT_TEMPLATE: &str = r#"[Setup]
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
ArchitecturesAllowed={{ARCHITECTURES_ALLOWED}}
ArchitecturesInstallIn64BitMode={{ARCHITECTURES_INSTALL_IN_64BIT_MODE}}

[Languages]
{% for locale in LOCALES %}
{% if locale == 'en' %}Name: "english"; MessagesFile: "compiler:Default.isl"{% endif %}
{% if locale == 'hy' %}Name: "armenian"; MessagesFile: "compiler:Languages\Armenian.isl"{% endif %}
{% if locale == 'bg' %}Name: "bulgarian"; MessagesFile: "compiler:Languages\Bulgarian.isl"{% endif %}
{% if locale == 'ca' %}Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"{% endif %}
{% if locale == 'zh' %}Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"{% endif %}
{% if locale == 'co' %}Name: "corsican"; MessagesFile: "compiler:Languages\Corsican.isl"{% endif %}
{% if locale == 'cs' %}Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"{% endif %}
{% if locale == 'da' %}Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"{% endif %}
{% if locale == 'nl' %}Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"{% endif %}
{% if locale == 'fi' %}Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"{% endif %}
{% if locale == 'fr' %}Name: "french"; MessagesFile: "compiler:Languages\French.isl"{% endif %}
{% if locale == 'de' %}Name: "german"; MessagesFile: "compiler:Languages\German.isl"{% endif %}
{% if locale == 'he' %}Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"{% endif %}
{% if locale == 'is' %}Name: "icelandic"; MessagesFile: "compiler:Languages\Icelandic.isl"{% endif %}
{% if locale == 'it' %}Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"{% endif %}
{% if locale == 'ja' %}Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"{% endif %}
{% if locale == 'no' %}Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"{% endif %}
{% if locale == 'pl' %}Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"{% endif %}
{% if locale == 'pt' %}Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"{% endif %}
{% if locale == 'ru' %}Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"{% endif %}
{% if locale == 'sk' %}Name: "slovak"; MessagesFile: "compiler:Languages\Slovak.isl"{% endif %}
{% if locale == 'sl' %}Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"{% endif %}
{% if locale == 'es' %}Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"{% endif %}
{% if locale == 'tr' %}Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"{% endif %}
{% if locale == 'uk' %}Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"{% endif %}
{% endfor %}

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: {% if CREATE_DESKTOP_ICON != true %}unchecked{% else %}checkedonce{% endif %}
Name: "launchAtStartup"; Description: "{cm:AutoStartProgram,{{DISPLAY_NAME}}}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: {% if LAUNCH_AT_STARTUP != true %}unchecked{% else %}checkedonce{% endif %}
[Files]
Source: "{{SOURCE_DIR}}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{{DISPLAY_NAME}}"; Filename: "{app}\{{EXECUTABLE_NAME}}"
Name: "{autodesktop}\{{DISPLAY_NAME}}"; Filename: "{app}\{{EXECUTABLE_NAME}}"; Tasks: desktopicon
Name: "{userstartup}\{{DISPLAY_NAME}}"; Filename: "{app}\{{EXECUTABLE_NAME}}"; WorkingDir: "{app}"; Tasks: launchAtStartup
[Run]
Filename: "{app}\{{EXECUTABLE_NAME}}"; Description: "{cm:LaunchProgram,{{DISPLAY_NAME}}}"; Flags: {% if PRIVILEGES_REQUIRED == 'admin' %}runascurrentuser{% endif %} nowait postinstall skipifsilent
"#;

const INNO_SETUP_ENV_VAR: &str = "INNO_SETUP_PATH";
const DEFAULT_INNO_SETUP_PATH: &str = r"C:\Program Files (x86)\Inno Setup 6";

/// Maps locale codes to Inno Setup language files, mirroring Dart's
/// `_localeToLanguageFile`.
const LOCALE_LANGUAGE_FILES: &[(&str, &str)] = &[
    ("en", "Default.isl"),
    ("hy", "Armenian.isl"),
    ("bg", "Bulgarian.isl"),
    ("ca", "Catalan.isl"),
    ("zh", "ChineseSimplified.isl"),
    ("co", "Corsican.isl"),
    ("cs", "Czech.isl"),
    ("da", "Danish.isl"),
    ("nl", "Dutch.isl"),
    ("fi", "Finnish.isl"),
    ("fr", "French.isl"),
    ("de", "German.isl"),
    ("he", "Hebrew.isl"),
    ("is", "Icelandic.isl"),
    ("it", "Italian.isl"),
    ("ja", "Japanese.isl"),
    ("no", "Norwegian.isl"),
    ("pl", "Polish.isl"),
    ("pt", "Portuguese.isl"),
    ("ru", "Russian.isl"),
    ("sk", "Slovak.isl"),
    ("sl", "Slovenian.isl"),
    ("es", "Spanish.isl"),
    ("tr", "Turkish.isl"),
    ("uk", "Ukrainian.isl"),
];

/// Schema of `windows/packaging/exe/make_config.yaml`, mirroring Dart's
/// `MakeExeConfig.fromJson`.
#[derive(Debug, Default, Deserialize)]
pub struct ExeMakeConfig {
    pub script_template: Option<String>,
    #[serde(alias = "appId")]
    pub app_id: Option<String>,
    pub executable_name: Option<String>,
    pub display_name: Option<String>,
    #[serde(alias = "appPublisher")]
    pub publisher_name: Option<String>,
    #[serde(alias = "appPublisherUrl")]
    pub publisher_url: Option<String>,
    pub create_desktop_icon: Option<bool>,
    pub launch_at_startup: Option<bool>,
    pub install_dir_name: Option<String>,
    pub setup_icon_file: Option<String>,
    pub privileges_required: Option<String>,
    pub locales: Option<Vec<String>>,
    pub architectures_allowed: Option<String>,
    pub architectures_install_in_64bit_mode: Option<String>,
}

impl ExeMakeConfig {
    fn load() -> Result<Self, PackageError> {
        let path = Path::new("windows/packaging/exe/make_config.yaml");
        if !path.exists() {
            return Ok(Self::default());
        }
        let content = std::fs::read_to_string(path).map_err(|e| {
            PackageError::General(format!("Failed to read {}: {}", path.display(), e))
        })?;
        serde_yaml::from_str(&content).map_err(|e| {
            PackageError::General(format!("Failed to parse {}: {}", path.display(), e))
        })
    }
}

/// Resolves the path to `ISCC.exe` using the same order as Dart's
/// `InnoSetupCompiler`:
/// 1. `INNO_SETUP_PATH` (a directory containing ISCC.exe)
/// 2. The default install path (`C:\Program Files (x86)\Inno Setup 6`)
/// 3. `iscc` found in `PATH`
fn resolve_iscc_path(inno_setup_path: Option<&str>) -> String {
    if let Some(dir) = inno_setup_path.filter(|p| !p.is_empty()) {
        let iscc = Path::new(dir).join("ISCC.exe");
        if iscc.is_file() {
            return iscc.display().to_string();
        }
    }
    let default_iscc = Path::new(DEFAULT_INNO_SETUP_PATH).join("ISCC.exe");
    if default_iscc.is_file() {
        return default_iscc.display().to_string();
    }
    "iscc".to_string()
}

/// The hint Dart prints when Inno Setup cannot be found.
fn inno_setup_missing_message() -> String {
    format!(
        "`Inno Setup 6` was not installed. Please install it (https://jrsoftware.org/isinfo.php), or set the `{}` environment variable to the installation path.",
        INNO_SETUP_ENV_VAR
    )
}

/// Filters locales to those whose `.isl` files exist at the resolved Inno
/// Setup location, mirroring Dart's `_getAvailableLocales`. When iscc is only
/// available via `PATH` the directory is unknown, so all locales are kept.
fn available_locales(locales: &[String], iscc_path: &str) -> Vec<String> {
    if locales.is_empty() {
        return vec!["en".to_string()];
    }
    if iscc_path == "iscc" {
        return locales.to_vec();
    }
    let inno_dir = Path::new(iscc_path).parent().unwrap_or(Path::new("."));
    let mut available = Vec::new();
    for locale in locales {
        let Some((code, isl)) = LOCALE_LANGUAGE_FILES
            .iter()
            .find(|(code, _)| code == locale)
        else {
            available.push(locale.clone());
            continue;
        };
        // Default.isl lives in the ISCC root directory, the others in
        // `Languages/`.
        if *code == "en" {
            if inno_dir.join(isl).exists() {
                available.push(locale.clone());
            }
            continue;
        }
        let lang_file = inno_dir.join("Languages").join(isl);
        if lang_file.exists() {
            available.push(locale.clone());
        } else {
            eprintln!(
                "[fastforge] Language file not found, skipping locale \"{}\": {}",
                locale,
                lang_file.display()
            );
        }
    }
    if available.is_empty() {
        vec!["en".to_string()]
    } else {
        available
    }
}

/// Variables passed to the Inno Setup script template, mirroring Dart's
/// `InnoSetupScript.createFile`. `None` values are left undefined (Dart
/// removes `null` entries), so they render empty and are falsy in `{% if %}`.
#[derive(Debug, Clone)]
struct IssVariables {
    app_id: String,
    app_name: String,
    app_version: String,
    executable_name: String,
    display_name: Option<String>,
    publisher_name: Option<String>,
    publisher_url: Option<String>,
    create_desktop_icon: Option<bool>,
    launch_at_startup: Option<bool>,
    install_dir_name: String,
    source_dir: String,
    output_base_filename: String,
    locales: Vec<String>,
    setup_icon_file: String,
    privileges_required: String,
    architectures_allowed: String,
    architectures_install_in_64bit_mode: String,
}

impl IssVariables {
    fn to_liquid_object(&self) -> liquid::Object {
        use liquid::model::Value;
        let mut object = liquid::Object::new();
        let mut set = |key: &'static str, value: Value| {
            object.insert(key.into(), value);
        };
        let s = |v: &str| Value::scalar(v.to_string());
        set("APP_ID", s(&self.app_id));
        set("APP_NAME", s(&self.app_name));
        set("APP_VERSION", s(&self.app_version));
        set("EXECUTABLE_NAME", s(&self.executable_name));
        if let Some(v) = &self.display_name {
            set("DISPLAY_NAME", s(v));
        }
        if let Some(v) = &self.publisher_name {
            set("PUBLISHER_NAME", s(v));
        }
        if let Some(v) = &self.publisher_url {
            set("PUBLISHER_URL", s(v));
        }
        if let Some(v) = self.create_desktop_icon {
            set("CREATE_DESKTOP_ICON", Value::scalar(v));
        }
        if let Some(v) = self.launch_at_startup {
            set("LAUNCH_AT_STARTUP", Value::scalar(v));
        }
        set("INSTALL_DIR_NAME", s(&self.install_dir_name));
        set("SOURCE_DIR", s(&self.source_dir));
        set("OUTPUT_BASE_FILENAME", s(&self.output_base_filename));
        set(
            "LOCALES",
            Value::Array(self.locales.iter().map(|l| s(l)).collect()),
        );
        set("SETUP_ICON_FILE", s(&self.setup_icon_file));
        set("PRIVILEGES_REQUIRED", s(&self.privileges_required));
        set("ARCHITECTURES_ALLOWED", s(&self.architectures_allowed));
        set(
            "ARCHITECTURES_INSTALL_IN_64BIT_MODE",
            s(&self.architectures_install_in_64bit_mode),
        );
        object
    }

    /// Renders a Liquid template (Dart's default or a custom one).
    fn render(&self, template: &str) -> Result<String, PackageError> {
        render_liquid(template, self.to_liquid_object())
    }
}

/// Renders a Liquid template leniently: like Dart's `liquid_engine`,
/// undefined variables render as empty (nil) instead of failing.
fn render_liquid(template: &str, variables: liquid::Object) -> Result<String, PackageError> {
    let parser = liquid::ParserBuilder::with_stdlib()
        .build()
        .map_err(|e| PackageError::General(format!("Failed to build Liquid parser: {}", e)))?;
    let template = parser
        .parse(template)
        .map_err(|e| PackageError::General(format!("Invalid Inno Setup script template: {}", e)))?;
    template
        .render(&LenientGlobals(variables))
        .map_err(|e| PackageError::General(format!("Failed to render Inno Setup script: {}", e)))
}

static NIL: liquid::model::Value = liquid::model::Value::Nil;

/// Liquid globals that resolve unknown top-level variables to `nil`.
#[derive(Debug)]
struct LenientGlobals(liquid::Object);

impl liquid::ValueView for LenientGlobals {
    fn as_debug(&self) -> &dyn std::fmt::Debug {
        self
    }
    fn render(&self) -> liquid::model::DisplayCow<'_> {
        self.0.render()
    }
    fn source(&self) -> liquid::model::DisplayCow<'_> {
        self.0.source()
    }
    fn type_name(&self) -> &'static str {
        self.0.type_name()
    }
    fn query_state(&self, state: liquid::model::State) -> bool {
        self.0.query_state(state)
    }
    fn to_kstr(&self) -> liquid::model::KStringCow<'_> {
        self.0.to_kstr()
    }
    fn to_value(&self) -> liquid::model::Value {
        self.0.to_value()
    }
    fn as_object(&self) -> Option<&dyn liquid::ObjectView> {
        Some(self)
    }
}

impl liquid::ObjectView for LenientGlobals {
    fn as_value(&self) -> &dyn liquid::ValueView {
        self
    }
    fn size(&self) -> i64 {
        liquid::ObjectView::size(&self.0)
    }
    fn keys<'k>(&'k self) -> Box<dyn Iterator<Item = liquid::model::KStringCow<'k>> + 'k> {
        liquid::ObjectView::keys(&self.0)
    }
    fn values<'k>(&'k self) -> Box<dyn Iterator<Item = &'k dyn liquid::ValueView> + 'k> {
        liquid::ObjectView::values(&self.0)
    }
    fn iter<'k>(
        &'k self,
    ) -> Box<dyn Iterator<Item = (liquid::model::KStringCow<'k>, &'k dyn liquid::ValueView)> + 'k>
    {
        liquid::ObjectView::iter(&self.0)
    }
    fn contains_key(&self, _index: &str) -> bool {
        true
    }
    fn get<'s>(&'s self, index: &str) -> Option<&'s dyn liquid::ValueView> {
        Some(liquid::ObjectView::get(&self.0, index).unwrap_or(&NIL))
    }
}

/// `<packagingDir>.iss` (Dart: `File('${packagingDirectory.path}.iss')`).
/// Appending avoids `with_extension`, which would cut the name at the last
/// dot of the version.
fn iss_path_for(pkg_dir: &Path) -> PathBuf {
    let mut path = pkg_dir.as_os_str().to_owned();
    path.push(".iss");
    PathBuf::from(path)
}

/// Dart's `outputBaseFileName`: the output file name with every `.exe`
/// removed.
fn output_base_filename(output_file: &Path) -> String {
    output_file
        .file_name()
        .unwrap_or_default()
        .to_string_lossy()
        .replace(".exe", "")
}

impl AppPackager for WindowsExePackager {
    fn name(&self) -> &str {
        "exe"
    }

    fn platform(&self) -> Platform {
        Platform::Windows
    }

    fn package_format(&self) -> &str {
        "exe"
    }

    #[cfg(not(target_os = "windows"))]
    fn is_supported_on_current_platform(&self) -> bool {
        false
    }

    fn package(&self, config: &PackageConfig) -> Result<PackageResult, PackageError> {
        let make_config = ExeMakeConfig::load()?;
        let pkg_dir = config.packaging_dir();

        // Copy the flutter build output into the packaging directory
        // (Dart's `copyPathSync`; includes hidden/system files).
        copy_dir_contents(&config.build_output_dir, &pkg_dir)?;

        let output_file = config.output_file();

        // Default executable: the first .exe in the packaging directory
        // (mirrors Dart's `defaultExecutableName`).
        let executable_name = match &make_config.executable_name {
            Some(name) => name.clone(),
            None => {
                let mut exes: Vec<PathBuf> = std::fs::read_dir(&pkg_dir)?
                    .filter_map(|e| e.ok())
                    .map(|e| e.path())
                    .filter(|p| p.is_file() && p.extension().is_some_and(|x| x == "exe"))
                    .collect();
                exes.sort();
                exes.first()
                    .and_then(|p| p.file_name().map(|f| f.to_string_lossy().to_string()))
                    .unwrap_or_else(|| format!("{}.exe", config.app_binary_name))
            }
        };

        // Absolute setup icon path (mirrors Dart, which joins with cwd);
        // empty when not configured.
        let setup_icon_file = make_config
            .setup_icon_file
            .as_ref()
            .map(|icon| {
                std::env::current_dir()
                    .map(|cwd| cwd.join(icon).display().to_string())
                    .unwrap_or_else(|_| icon.clone())
            })
            .unwrap_or_default();

        let iscc_path = resolve_iscc_path(config.env_var(INNO_SETUP_ENV_VAR).as_deref());
        let locales = available_locales(
            &make_config
                .locales
                .clone()
                .filter(|l| !l.is_empty())
                .unwrap_or_else(|| vec!["en".to_string()]),
            &iscc_path,
        );

        let variables = IssVariables {
            // Dart requires `app_id`; fall back to the app name.
            app_id: make_config
                .app_id
                .clone()
                .unwrap_or_else(|| config.app_name.clone()),
            app_name: config.app_name.clone(),
            app_version: config.app_version.clone(),
            executable_name,
            // Inno Setup requires AppName; fall back to the app name instead
            // of rendering it empty.
            display_name: Some(
                make_config
                    .display_name
                    .clone()
                    .unwrap_or_else(|| config.app_name.clone()),
            ),
            publisher_name: make_config.publisher_name.clone(),
            publisher_url: make_config.publisher_url.clone(),
            create_desktop_icon: make_config.create_desktop_icon,
            launch_at_startup: make_config.launch_at_startup,
            install_dir_name: make_config
                .install_dir_name
                .clone()
                .unwrap_or_else(|| format!("{{autopf64}}\\{}", config.app_name)),
            source_dir: pkg_dir
                .file_name()
                .map(|f| f.to_string_lossy().to_string())
                .unwrap_or_default(),
            output_base_filename: output_base_filename(&output_file),
            locales,
            setup_icon_file,
            privileges_required: make_config
                .privileges_required
                .clone()
                .unwrap_or_else(|| "none".to_string()),
            architectures_allowed: make_config
                .architectures_allowed
                .clone()
                .unwrap_or_else(|| "x64compatible".to_string()),
            architectures_install_in_64bit_mode: make_config
                .architectures_install_in_64bit_mode
                .clone()
                .unwrap_or_else(|| "x64compatible".to_string()),
        };

        // Render the script (custom template when configured, mirroring
        // Dart's `script_template` support).
        let template = match &make_config.script_template {
            Some(template_name) => {
                let template_path = Path::new("windows/packaging/exe").join(template_name);
                std::fs::read_to_string(&template_path).map_err(|e| {
                    PackageError::General(format!(
                        "Failed to read script template {}: {}",
                        template_path.display(),
                        e
                    ))
                })?
            }
            None => DEFAULT_TEMPLATE.to_string(),
        };
        let content = variables.render(&template)?;

        // The .iss file sits next to the packaging directory (in the version
        // output dir), so `OutputDir=.` and `SOURCE_DIR\*` resolve correctly.
        // A UTF-8 BOM is prepended, mirroring Dart.
        let iss_path = iss_path_for(&pkg_dir);
        std::fs::write(&iss_path, format!("\u{FEFF}{}", content))?;

        let out = Command::new(&iscc_path).arg(&iss_path).output();
        let out = match out {
            Ok(out) => out,
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => {
                return Err(PackageError::MissingTool(inno_setup_missing_message()));
            }
            Err(e) => return Err(PackageError::MissingTool(format!("{}: {}", iscc_path, e))),
        };
        if !out.status.success() {
            return Err(PackageError::CommandFailed {
                command: iscc_path,
                stderr: format!(
                    "{}{}",
                    String::from_utf8_lossy(&out.stdout),
                    String::from_utf8_lossy(&out.stderr)
                ),
            });
        }

        std::fs::remove_file(&iss_path).ok();
        std::fs::remove_dir_all(&pkg_dir).ok();
        config.resolve_result(output_file)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_variables() -> IssVariables {
        IssVariables {
            app_id: "6BCF1E88-6912-4D77-8FE8-B10A2A1B5A0E".into(),
            app_name: "hola_amigos".into(),
            app_version: "1.2.3+4".into(),
            executable_name: "hola_amigos.exe".into(),
            display_name: Some("Hola Amigos".into()),
            publisher_name: Some("ACME".into()),
            publisher_url: Some("https://example.com".into()),
            create_desktop_icon: Some(true),
            launch_at_startup: None,
            install_dir_name: "{autopf64}\\hola_amigos".into(),
            source_dir: "hola_amigos-1.2.3+4-windows-setup_exe".into(),
            output_base_filename: "hola_amigos-1.2.3+4-windows-setup".into(),
            locales: vec!["en".into(), "zh".into()],
            setup_icon_file: "C:\\proj\\icon.ico".into(),
            privileges_required: "admin".into(),
            architectures_allowed: "x64compatible".into(),
            architectures_install_in_64bit_mode: "x64compatible".into(),
        }
    }

    #[test]
    fn default_script_contains_all_sections() {
        let iss = test_variables().render(DEFAULT_TEMPLATE).unwrap();
        assert!(iss.starts_with("[Setup]\nAppId=6BCF1E88-6912-4D77-8FE8-B10A2A1B5A0E\n"));
        assert!(iss.contains("AppVersion=1.2.3+4"));
        assert!(iss.contains("AppName=Hola Amigos"));
        assert!(iss.contains("AppPublisher=ACME"));
        assert!(iss.contains("AppPublisherURL=https://example.com"));
        assert!(iss.contains("DefaultDirName={autopf64}\\hola_amigos"));
        assert!(iss.contains("OutputBaseFilename=hola_amigos-1.2.3+4-windows-setup\n"));
        assert!(iss.contains("SetupIconFile=C:\\proj\\icon.ico"));
        assert!(iss.contains("PrivilegesRequired=admin"));
        assert!(iss.contains("ArchitecturesAllowed=x64compatible"));
        assert!(iss.contains("Name: \"english\"; MessagesFile: \"compiler:Default.isl\""));
        assert!(iss.contains(
            "Name: \"chinesesimplified\"; MessagesFile: \"compiler:Languages\\ChineseSimplified.isl\""
        ));
        assert!(!iss.contains("armenian"));
        // CREATE_DESKTOP_ICON = true, LAUNCH_AT_STARTUP undefined.
        assert!(iss.contains(
            "Name: \"desktopicon\"; Description: \"{cm:CreateDesktopIcon}\"; GroupDescription: \"{cm:AdditionalIcons}\"; Flags: checkedonce\n"
        ));
        assert!(iss.contains(
            "Name: \"launchAtStartup\"; Description: \"{cm:AutoStartProgram,Hola Amigos}\"; GroupDescription: \"{cm:AdditionalIcons}\"; Flags: unchecked\n"
        ));
        assert!(
            iss.contains(
                "Source: \"hola_amigos-1.2.3+4-windows-setup_exe\\*\"; DestDir: \"{app}\""
            )
        );
        assert!(iss.contains(
            "Name: \"{autoprograms}\\Hola Amigos\"; Filename: \"{app}\\hola_amigos.exe\""
        ));
        assert!(iss.ends_with(
            "Filename: \"{app}\\hola_amigos.exe\"; Description: \"{cm:LaunchProgram,Hola Amigos}\"; Flags: runascurrentuser nowait postinstall skipifsilent\n"
        ));
    }

    #[test]
    fn default_script_languages_block_matches_liquid_whitespace() {
        // Liquid keeps the newline after every `{% if %}` line, exactly like
        // Dart's liquid_engine, so each locale produces a block of blank
        // lines around its `Name:` entry.
        let mut vars = test_variables();
        vars.locales = vec!["en".into()];
        let iss = vars.render(DEFAULT_TEMPLATE).unwrap();
        let start = iss.find("[Languages]\n").unwrap() + "[Languages]\n".len();
        let end = iss.find("[Tasks]").unwrap();
        let block = &iss[start..end];
        // "{% for %}\n" + the matching line + 24 empty `{% if %}` lines, then
        // "{% endfor %}\n" and the blank line before `[Tasks]`.
        let expected = format!(
            "\n{}{}\n\n",
            "Name: \"english\"; MessagesFile: \"compiler:Default.isl\"\n",
            "\n".repeat(24)
        );
        assert_eq!(block, expected);
    }

    #[test]
    fn non_admin_run_flags() {
        let mut vars = test_variables();
        vars.privileges_required = "none".into();
        let iss = vars.render(DEFAULT_TEMPLATE).unwrap();
        assert!(iss.contains("Flags:  nowait postinstall skipifsilent"));
        assert!(!iss.contains("runascurrentuser"));
    }

    #[test]
    fn custom_template_supports_liquid_logic_and_whitespace() {
        let iss = test_variables()
            .render(
                "[Setup]\nAppId={{ APP_ID }}\nAppName={{DISPLAY_NAME}}\nApp={{ APP_NAME }}\n{% for locale in LOCALES %}L={{ locale }};{% endfor %}\n{% if CREATE_DESKTOP_ICON %}desktop{% endif %}{% if LAUNCH_AT_STARTUP %}startup{% else %}nostartup{% endif %}\nSource: \"{{SOURCE_DIR}}\\*\"\nUnknown=[{{ NOT_A_VARIABLE }}]{% if NOT_A_VARIABLE %}x{% endif %}",
            )
            .unwrap();
        assert_eq!(
            iss,
            "[Setup]\nAppId=6BCF1E88-6912-4D77-8FE8-B10A2A1B5A0E\nAppName=Hola Amigos\nApp=hola_amigos\nL=en;L=zh;\ndesktopnostartup\nSource: \"hola_amigos-1.2.3+4-windows-setup_exe\\*\"\nUnknown=[]"
        );
    }

    #[test]
    fn undefined_optional_variables_render_empty() {
        let mut vars = test_variables();
        vars.publisher_name = None;
        vars.publisher_url = None;
        let iss = vars
            .render("P={{PUBLISHER_NAME}}|U={{ PUBLISHER_URL }}|{% if PUBLISHER_URL %}set{% else %}unset{% endif %}")
            .unwrap();
        assert_eq!(iss, "P=|U=|unset");
    }

    #[test]
    fn iss_path_and_output_base_filename() {
        let pkg_dir = Path::new("dist/1.2.3+4/hola-1.2.3+4-windows-setup_exe");
        assert_eq!(
            iss_path_for(pkg_dir),
            PathBuf::from("dist/1.2.3+4/hola-1.2.3+4-windows-setup_exe.iss")
        );
        assert_eq!(
            output_base_filename(Path::new("dist/1.2.3+4/hola-1.2.3+4-windows-setup.exe")),
            "hola-1.2.3+4-windows-setup"
        );
        assert_eq!(
            output_base_filename(Path::new("my.exe.tool.exe")),
            "my.tool"
        );
    }

    #[test]
    fn iscc_resolution_prefers_inno_setup_path() {
        let tmp = tempfile::tempdir().unwrap();
        // Without ISCC.exe in the directory the variable is ignored.
        let resolved = resolve_iscc_path(Some(&tmp.path().display().to_string()));
        assert!(resolved == "iscc" || resolved.contains("Inno Setup 6"));
        std::fs::write(tmp.path().join("ISCC.exe"), b"").unwrap();
        assert_eq!(
            resolve_iscc_path(Some(&tmp.path().display().to_string())),
            tmp.path().join("ISCC.exe").display().to_string()
        );
    }

    #[test]
    fn inno_setup_path_is_read_from_config_environment() {
        let tmp = tempfile::tempdir().unwrap();
        std::fs::write(tmp.path().join("ISCC.exe"), b"").unwrap();
        let mut environment = std::collections::HashMap::new();
        environment.insert(
            INNO_SETUP_ENV_VAR.to_string(),
            tmp.path().display().to_string(),
        );
        let config = PackageConfig {
            app_name: "demo".into(),
            app_binary_name: "demo".into(),
            app_version: "1.0.0".into(),
            build_mode: "release".into(),
            platform: Platform::Windows,
            flavor: None,
            channel: None,
            artifact_name: None,
            package_format: "exe".into(),
            is_installer: true,
            build_output_dir: PathBuf::new(),
            build_output_files: vec![],
            output_dir: PathBuf::new(),
            environment,
        };
        assert_eq!(
            resolve_iscc_path(config.env_var(INNO_SETUP_ENV_VAR).as_deref()),
            tmp.path().join("ISCC.exe").display().to_string()
        );
    }

    #[test]
    fn locales_filtering() {
        assert_eq!(available_locales(&[], "iscc"), vec!["en".to_string()]);
        // With PATH-resolved iscc all locales are kept
        assert_eq!(
            available_locales(&["en".to_string(), "zh".to_string()], "iscc"),
            vec!["en".to_string(), "zh".to_string()]
        );
        let tmp = tempfile::tempdir().unwrap();
        let iscc = tmp.path().join("ISCC.exe");
        std::fs::write(tmp.path().join("Default.isl"), b"").unwrap();
        std::fs::create_dir_all(tmp.path().join("Languages")).unwrap();
        std::fs::write(tmp.path().join("Languages/German.isl"), b"").unwrap();
        assert_eq!(
            available_locales(
                &["en".into(), "de".into(), "ja".into(), "xx".into()],
                &iscc.display().to_string()
            ),
            vec!["en".to_string(), "de".to_string(), "xx".to_string()]
        );
    }
}
