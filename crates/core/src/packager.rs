use crate::model::Platform;
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use thiserror::Error;

// ── Types ─────────────────────────────────────────────────────────────────────

/// Dart's `_kArtifactName` (api/make_config.dart).
const ARTIFACT_NAME_TEMPLATE: &str = "{{name}}{{#flavor}}-{{flavor}}{{/flavor}}-{{build_name}}{{#has_build_number}}+{{build_number}}{{/has_build_number}}{{#is_profile}}-{{build_mode}}{{/is_profile}}-{{platform}}{{#is_installer}}-setup{{/is_installer}}{{#ext}}.{{ext}}{{/ext}}";

/// Dart's `_kArtifactNameWithChannel`: the channel replaces the flavor segment.
const ARTIFACT_NAME_WITH_CHANNEL_TEMPLATE: &str = "{{name}}-{{channel}}-{{build_name}}{{#has_build_number}}+{{build_number}}{{/has_build_number}}{{#is_profile}}-{{build_mode}}{{/is_profile}}-{{platform}}{{#is_installer}}-setup{{/is_installer}}{{#ext}}.{{ext}}{{/ext}}";

/// A value in the mustache rendering context. Mirrors the Dart types placed
/// in `MakeConfig.outputArtifactPath`'s variable map (`bool`, `String`,
/// `null`).
#[derive(Debug, Clone, PartialEq)]
enum MustacheValue {
    Null,
    Bool(bool),
    Str(String),
}

impl MustacheValue {
    fn from_option(value: Option<String>) -> Self {
        value.map(MustacheValue::Str).unwrap_or(MustacheValue::Null)
    }

    /// Dart's `value.toString()` (`null` renders as an empty string).
    fn render(&self) -> String {
        match self {
            MustacheValue::Null => String::new(),
            MustacheValue::Bool(b) => b.to_string(),
            MustacheValue::Str(s) => s.clone(),
        }
    }
}

/// The variables Dart's `MakeConfig.outputArtifactPath` passes to the
/// artifact-name template.
fn artifact_variables(config: &PackageConfig) -> Vec<(&'static str, MustacheValue)> {
    let parts: Vec<&str> = config.app_version.split('+').collect();
    let build_name = parts.first().copied().unwrap_or_default().to_string();
    let build_number = (parts.len() > 1).then(|| parts[parts.len() - 1].to_string());
    let ext = (!config.package_format.is_empty()).then(|| config.package_format.clone());
    vec![
        ("is_installer", MustacheValue::Bool(config.is_installer)),
        (
            "is_profile",
            MustacheValue::Bool(config.build_mode == "profile"),
        ),
        (
            "has_build_number",
            MustacheValue::Bool(build_number.is_some()),
        ),
        ("name", MustacheValue::Str(config.app_name.clone())),
        ("version", MustacheValue::Str(config.app_version.clone())),
        ("build_name", MustacheValue::Str(build_name)),
        ("build_number", MustacheValue::from_option(build_number)),
        ("build_mode", MustacheValue::Str(config.build_mode.clone())),
        (
            "platform",
            MustacheValue::Str(config.platform.as_str().to_string()),
        ),
        ("flavor", MustacheValue::from_option(config.flavor.clone())),
        (
            "channel",
            MustacheValue::from_option(config.channel.clone()),
        ),
        ("ext", MustacheValue::from_option(ext)),
    ]
}

/// Renders the artifact file name, mirroring Dart's
/// `MakeConfig.outputArtifactPath`: a custom `artifact_name` template wins,
/// otherwise the channel template (when a channel is set) or the default one.
/// See [`render_mustache`] for the supported syntax.
fn render_artifact_name(config: &PackageConfig) -> String {
    let template = match (&config.artifact_name, &config.channel) {
        (Some(template), _) => template.as_str(),
        (None, Some(_)) => ARTIFACT_NAME_WITH_CHANNEL_TEMPLATE,
        (None, None) => ARTIFACT_NAME_TEMPLATE,
    };
    render_mustache(template, &artifact_variables(config))
}

#[derive(Debug)]
enum MustacheNode {
    Text(String),
    Variable {
        name: String,
        escape: bool,
    },
    Section {
        name: String,
        inverted: bool,
        children: Vec<MustacheNode>,
    },
}

/// Parses a mustache template into a node tree. Malformed input is handled
/// leniently: an unterminated `{{` is literal text, stray closing tags are
/// dropped and unclosed sections end at the end of the template.
fn parse_mustache(template: &str) -> Vec<MustacheNode> {
    // Stack of (section name, inverted, children); the root has no name.
    let mut stack: Vec<(Option<String>, bool, Vec<MustacheNode>)> = vec![(None, false, vec![])];
    let mut rest = template;

    fn push(stack: &mut [(Option<String>, bool, Vec<MustacheNode>)], node: MustacheNode) {
        if let Some(top) = stack.last_mut() {
            top.2.push(node);
        }
    }

    while let Some(start) = rest.find("{{") {
        if start > 0 {
            push(&mut stack, MustacheNode::Text(rest[..start].to_string()));
        }
        let after = &rest[start + 2..];
        // Triple mustache `{{{name}}}` (unescaped).
        if let Some(inner) = after.strip_prefix('{')
            && let Some(end) = inner.find("}}}")
        {
            push(
                &mut stack,
                MustacheNode::Variable {
                    name: inner[..end].trim().to_string(),
                    escape: false,
                },
            );
            rest = &inner[end + 3..];
            continue;
        }
        let Some(end) = after.find("}}") else {
            push(&mut stack, MustacheNode::Text(rest[start..].to_string()));
            rest = "";
            break;
        };
        let tag = after[..end].trim();
        rest = &after[end + 2..];

        let mut chars = tag.chars();
        match chars.next() {
            Some('#') | Some('^') => {
                let inverted = tag.starts_with('^');
                stack.push((Some(chars.as_str().trim().to_string()), inverted, vec![]));
            }
            Some('/') => {
                let name = chars.as_str().trim();
                // Close the innermost matching section (and anything unclosed
                // inside it); ignore stray closing tags.
                if let Some(pos) = stack
                    .iter()
                    .rposition(|(n, _, _)| n.as_deref() == Some(name))
                    && pos > 0
                {
                    while stack.len() > pos {
                        let (name, inverted, children) = stack.pop().unwrap();
                        push(
                            &mut stack,
                            MustacheNode::Section {
                                name: name.unwrap_or_default(),
                                inverted,
                                children,
                            },
                        );
                    }
                }
            }
            Some('&') => push(
                &mut stack,
                MustacheNode::Variable {
                    name: chars.as_str().trim().to_string(),
                    escape: false,
                },
            ),
            // Comments, partials and delimiter changes render nothing.
            Some('!') | Some('>') | Some('=') => {}
            _ => push(
                &mut stack,
                MustacheNode::Variable {
                    name: tag.to_string(),
                    escape: true,
                },
            ),
        }
    }
    if !rest.is_empty() {
        push(&mut stack, MustacheNode::Text(rest.to_string()));
    }
    while stack.len() > 1 {
        let (name, inverted, children) = stack.pop().unwrap();
        push(
            &mut stack,
            MustacheNode::Section {
                name: name.unwrap_or_default(),
                inverted,
                children,
            },
        );
    }
    stack
        .pop()
        .map(|(_, _, children)| children)
        .unwrap_or_default()
}

/// HTML-escapes a value exactly like Dart's `mustache_template`
/// (`& < > " ' /`).
fn mustache_escape(value: &str) -> String {
    let mut out = String::with_capacity(value.len());
    for c in value.chars() {
        match c {
            '&' => out.push_str("&amp;"),
            '<' => out.push_str("&lt;"),
            '>' => out.push_str("&gt;"),
            '"' => out.push_str("&quot;"),
            '\'' => out.push_str("&#x27;"),
            '/' => out.push_str("&#x2F;"),
            c => out.push(c),
        }
    }
    out
}

/// Resolves a tag name against the context stack (`None` = no such
/// property). Pushed section values are scalars without named properties,
/// so names resolve against the root variables; `.` is the innermost value
/// and dotted names never resolve (scalars have no members).
fn mustache_lookup(
    name: &str,
    variables: &[(&'static str, MustacheValue)],
    stack: &[MustacheValue],
) -> Option<MustacheValue> {
    if name == "." {
        return stack.last().cloned();
    }
    if name.contains('.') {
        return None;
    }
    variables
        .iter()
        .find(|(key, _)| *key == name)
        .map(|(_, value)| value.clone())
}

fn render_mustache_nodes(
    nodes: &[MustacheNode],
    variables: &[(&'static str, MustacheValue)],
    stack: &mut Vec<MustacheValue>,
    out: &mut String,
) {
    for node in nodes {
        match node {
            MustacheNode::Text(text) => out.push_str(text),
            MustacheNode::Variable { name, escape } => {
                // Unknown variables render empty (Dart's strict mode would
                // throw; the Rust CLI stays lenient).
                if let Some(value) = mustache_lookup(name, variables, stack) {
                    let rendered = value.render();
                    if *escape {
                        out.push_str(&mustache_escape(&rendered));
                    } else {
                        out.push_str(&rendered);
                    }
                }
            }
            MustacheNode::Section {
                name,
                inverted,
                children,
            } => {
                let value = mustache_lookup(name, variables, stack);
                // Dart truthiness: `null`/`false`/missing are falsy; `true`
                // and every string (including the empty string) are truthy.
                let truthy = match &value {
                    None | Some(MustacheValue::Null) | Some(MustacheValue::Bool(false)) => false,
                    Some(MustacheValue::Bool(true)) | Some(MustacheValue::Str(_)) => true,
                };
                if truthy != *inverted {
                    stack.push(value.unwrap_or(MustacheValue::Null));
                    render_mustache_nodes(children, variables, stack, out);
                    stack.pop();
                }
            }
        }
    }
}

/// Minimal mustache renderer matching Dart's `mustache_template` for the
/// artifact-name use case: `{{var}}` (HTML-escaped), `{{{var}}}` / `{{&var}}`
/// (unescaped), `{{#section}}`/`{{^inverted}}` sections (nested allowed),
/// `{{.}}` and `{{! comments }}`. Unknown variables render empty.
fn render_mustache(template: &str, variables: &[(&'static str, MustacheValue)]) -> String {
    let nodes = parse_mustache(template);
    let mut out = String::new();
    render_mustache_nodes(&nodes, variables, &mut Vec::new(), &mut out);
    out
}

#[derive(Debug, Clone)]
pub struct PackageConfig {
    pub app_name: String,
    pub app_binary_name: String,
    pub app_version: String,
    pub build_mode: String,
    pub platform: Platform,
    pub flavor: Option<String>,
    pub channel: Option<String>,
    pub artifact_name: Option<String>,
    pub package_format: String,
    pub is_installer: bool,
    pub build_output_dir: PathBuf,
    pub build_output_files: Vec<PathBuf>,
    pub output_dir: PathBuf,
    /// Variables from `distribute_options.yaml` (global/release/job) layered
    /// over the process environment, as Dart passes them to the packagers
    /// (e.g. `INNO_SETUP_PATH`). Lookups fall back to the process environment.
    pub environment: HashMap<String, String>,
}

impl PackageConfig {
    pub fn output_file_name(&self) -> String {
        render_artifact_name(self)
    }

    pub fn version_output_dir(&self) -> PathBuf {
        let dir = self.output_dir.join(&self.app_version);
        if !dir.exists() {
            std::fs::create_dir_all(&dir).ok();
        }
        dir
    }

    pub fn output_file(&self) -> PathBuf {
        self.version_output_dir().join(self.output_file_name())
    }

    pub fn packaging_dir(&self) -> PathBuf {
        let stem = if self.package_format.is_empty() {
            format!("{}_direct", self.output_file_name())
        } else {
            self.output_file_name().replace(
                &format!(".{}", self.package_format),
                &format!("_{}", self.package_format),
            )
        };
        let dir = self.version_output_dir().join(stem);
        if dir.exists() {
            std::fs::remove_dir_all(&dir).ok();
        }
        std::fs::create_dir_all(&dir).ok();
        dir
    }

    /// Looks up a variable in `environment`, then the process environment.
    /// Empty values count as unset.
    pub fn env_var(&self, key: &str) -> Option<String> {
        self.environment
            .get(key)
            .cloned()
            .filter(|v| !v.is_empty())
            .or_else(|| std::env::var(key).ok().filter(|v| !v.is_empty()))
    }

    pub fn first_build_output_file(&self) -> Option<&Path> {
        self.build_output_files.first().map(|p| p.as_path())
    }

    /// Verifies that `artifact` exists and wraps it in a [`PackageResult`],
    /// mirroring Dart's `DefaultMakeResultResolver`: an empty
    /// `package_format` means the artifact is a directory, otherwise a file.
    pub fn resolve_result(&self, artifact: PathBuf) -> Result<PackageResult, PackageError> {
        PackageResult::resolve(artifact, self.package_format.is_empty())
    }
}

#[derive(Debug)]
pub struct PackageResult {
    pub artifacts: Vec<PathBuf>,
}

impl PackageResult {
    /// Builds a result for a single artifact after checking it exists,
    /// failing with Dart's `MakeError('No output file found.')` /
    /// `MakeError('No output directory found.')` messages otherwise.
    pub fn resolve(artifact: PathBuf, is_directory: bool) -> Result<Self, PackageError> {
        if is_directory {
            if !artifact.is_dir() {
                return Err(PackageError::General("No output directory found.".into()));
            }
        } else if !artifact.is_file() {
            return Err(PackageError::General("No output file found.".into()));
        }
        Ok(Self {
            artifacts: vec![artifact],
        })
    }
}

#[derive(Debug, Error)]
pub enum PackageError {
    #[error("{0}")]
    General(String),
    #[error("Missing tool: {0}")]
    MissingTool(String),
    #[error("Command '{command}' failed: {stderr}")]
    CommandFailed { command: String, stderr: String },
    #[error("Not found: {0}")]
    NotFound(String),
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
}

// ── Trait ─────────────────────────────────────────────────────────────────────

pub trait AppPackager {
    fn name(&self) -> &str;
    fn platform(&self) -> Platform;
    fn package_format(&self) -> &str;

    fn is_supported_on_current_platform(&self) -> bool {
        true
    }

    fn matches(&self, platform: &Platform, target: Option<&str>) -> bool {
        self.platform() == *platform && target.is_none_or(|t| self.name() == t)
    }

    fn package(&self, config: &PackageConfig) -> Result<PackageResult, PackageError>;
}

#[cfg(test)]
mod tests {
    use super::*;

    fn base_config() -> PackageConfig {
        PackageConfig {
            app_name: "hello_world".to_string(),
            app_binary_name: "hello_world".to_string(),
            app_version: "1.2.3+4".to_string(),
            build_mode: "release".to_string(),
            platform: Platform::Linux,
            flavor: None,
            channel: None,
            artifact_name: None,
            package_format: "deb".to_string(),
            is_installer: true,
            build_output_dir: PathBuf::new(),
            build_output_files: vec![],
            output_dir: PathBuf::new(),
            environment: Default::default(),
        }
    }

    #[test]
    fn default_artifact_name() {
        assert_eq!(
            base_config().output_file_name(),
            "hello_world-1.2.3+4-linux-setup.deb"
        );
    }

    #[test]
    fn flavor_artifact_name() {
        let mut config = base_config();
        config.flavor = Some("dev".to_string());
        assert_eq!(
            config.output_file_name(),
            "hello_world-dev-1.2.3+4-linux-setup.deb"
        );
    }

    #[test]
    fn channel_artifact_name_replaces_flavor_segment() {
        let mut config = base_config();
        config.flavor = Some("dev".to_string());
        config.channel = Some("beta".to_string());
        assert_eq!(
            config.output_file_name(),
            "hello_world-beta-1.2.3+4-linux-setup.deb"
        );
    }

    #[test]
    fn artifact_name_template_variables() {
        let mut config = base_config();
        config.artifact_name = Some("{{name}}_{{build_name}}_amd64.{{ext}}".to_string());
        assert_eq!(config.output_file_name(), "hello_world_1.2.3_amd64.deb");
    }

    #[test]
    fn artifact_name_template_sections() {
        let mut config = base_config();
        config.artifact_name = Some(
            "{{name}}{{#flavor}}-{{flavor}}{{/flavor}}-{{build_name}}{{#has_build_number}}+{{build_number}}{{/has_build_number}}{{#is_profile}}-{{build_mode}}{{/is_profile}}-{{platform}}{{#is_installer}}-setup{{/is_installer}}{{#ext}}.{{ext}}{{/ext}}"
                .to_string(),
        );
        // Matches Dart's default template output exactly
        assert_eq!(
            config.output_file_name(),
            "hello_world-1.2.3+4-linux-setup.deb"
        );
    }

    #[test]
    fn artifact_name_literal_passthrough() {
        let mut config = base_config();
        config.artifact_name = Some("MyApp-Installer.deb".to_string());
        assert_eq!(config.output_file_name(), "MyApp-Installer.deb");
    }

    #[test]
    fn default_artifact_name_variants() {
        let mut config = base_config();
        config.app_version = "1.2.3".to_string();
        config.build_mode = "profile".to_string();
        config.is_installer = false;
        config.package_format = String::new();
        assert_eq!(config.output_file_name(), "hello_world-1.2.3-profile-linux");
    }

    #[test]
    fn artifact_name_inverted_sections() {
        let mut config = base_config();
        config.artifact_name =
            Some("{{name}}{{^flavor}}-noflavor{{/flavor}}{{^is_profile}}-rel{{/is_profile}}{{^is_installer}}-portable{{/is_installer}}{{^unknown}}-u{{/unknown}}".to_string());
        assert_eq!(config.output_file_name(), "hello_world-noflavor-rel-u");
        config.flavor = Some("dev".to_string());
        assert_eq!(config.output_file_name(), "hello_world-rel-u");
    }

    #[test]
    fn artifact_name_escaping() {
        let mut config = base_config();
        config.flavor = Some("a/b&<c>\"d'".to_string());
        config.artifact_name = Some("{{flavor}}|{{{flavor}}}|{{&flavor}}|{{ flavor }}".to_string());
        assert_eq!(
            config.output_file_name(),
            "a&#x2F;b&amp;&lt;c&gt;&quot;d&#x27;|a/b&<c>\"d'|a/b&<c>\"d'|a&#x2F;b&amp;&lt;c&gt;&quot;d&#x27;"
        );
    }

    #[test]
    fn artifact_name_empty_string_is_truthy() {
        // Dart's mustache_template renders sections for any non-null string.
        let mut config = base_config();
        config.flavor = Some(String::new());
        config.artifact_name = Some("x{{#flavor}}-[{{flavor}}{{.}}]{{/flavor}}".to_string());
        assert_eq!(config.output_file_name(), "x-[]");
    }

    #[test]
    fn artifact_name_unknown_and_bool_variables() {
        let mut config = base_config();
        config.artifact_name =
            Some("{{missing}}{{a.b}}{{is_installer}}-{{has_build_number}}{{! comment }}{{#is_installer}}-{{.}}{{/is_installer}}".to_string());
        assert_eq!(config.output_file_name(), "true-true-true");
    }

    #[test]
    fn artifact_name_malformed_templates_are_lenient() {
        let mut config = base_config();
        config.artifact_name = Some("{{name}}{{/nope}}{{#is_installer}}-x".to_string());
        assert_eq!(config.output_file_name(), "hello_world-x");
        config.artifact_name = Some("{{name}}-{{oops".to_string());
        assert_eq!(config.output_file_name(), "hello_world-{{oops");
    }

    #[test]
    fn resolve_result_checks_artifact_existence() {
        let dir = std::env::temp_dir().join(format!("ff_resolve_{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let file = dir.join("a.zip");
        std::fs::write(&file, b"x").unwrap();

        let config = base_config();
        assert!(config.resolve_result(file.clone()).is_ok());
        let err = config.resolve_result(dir.join("missing.zip")).unwrap_err();
        assert_eq!(err.to_string(), "No output file found.");
        // A directory is not a file artifact.
        assert_eq!(
            config.resolve_result(dir.clone()).unwrap_err().to_string(),
            "No output file found."
        );

        let mut direct = base_config();
        direct.package_format = String::new();
        assert!(direct.resolve_result(dir.clone()).is_ok());
        assert_eq!(
            direct
                .resolve_result(dir.join("missing"))
                .unwrap_err()
                .to_string(),
            "No output directory found."
        );
        std::fs::remove_dir_all(&dir).ok();
    }
}
