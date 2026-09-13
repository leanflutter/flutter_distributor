use serde::{Deserialize, Serialize};

/// Platforms a project can target. Mirrors `fastforge_core::Platform`, but is
/// declared here so the wire contract does not move whenever fastforge's
/// internals do.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Platform {
    Android,
    Ios,
    Macos,
    Windows,
    Linux,
    Web,
}

impl Platform {
    pub const ALL: [Platform; 6] = [
        Platform::Android,
        Platform::Ios,
        Platform::Macos,
        Platform::Windows,
        Platform::Linux,
        Platform::Web,
    ];

    pub fn as_str(self) -> &'static str {
        match self {
            Platform::Android => "android",
            Platform::Ios => "ios",
            Platform::Macos => "macos",
            Platform::Windows => "windows",
            Platform::Linux => "linux",
            Platform::Web => "web",
        }
    }

    pub fn label(self) -> &'static str {
        match self {
            Platform::Android => "Android",
            Platform::Ios => "iOS",
            Platform::Macos => "macOS",
            Platform::Windows => "Windows",
            Platform::Linux => "Linux",
            Platform::Web => "Web",
        }
    }

    pub fn parse(value: &str) -> Option<Platform> {
        Platform::ALL
            .into_iter()
            .find(|platform| platform.as_str() == value)
    }
}

/// A project is the top-level object: there is no workspace above it yet. When
/// one is introduced it wraps projects, so nothing below this type changes.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Project {
    pub id: String,
    pub name: String,
    /// Local checkout. Present in `local` mode only.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub path: Option<String>,
    /// Git remote. Present in `cloud` mode only.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub repo: Option<String>,
    #[serde(default)]
    pub platforms: Vec<Platform>,
    /// Whether `.fastforge/config.yaml` exists. Drives the empty state on the
    /// stores page: without it there is nothing to read.
    pub has_fastforge_config: bool,
    /// RFC 3339. Produced by the host — this crate has no clock.
    pub created_at: String,
    pub updated_at: String,
}

/// The list projection. Kept separate from [`Project`] so list endpoints do not
/// have to invent values for fields they do not read from disk.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProjectSummary {
    pub id: String,
    pub name: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub path: Option<String>,
    #[serde(default)]
    pub platforms: Vec<Platform>,
    pub has_fastforge_config: bool,
    /// Set when the registry points at a directory that no longer exists.
    #[serde(default)]
    pub missing: bool,
}

/// Derives a project id from its canonical path.
///
/// Stable across restarts and machines-with-the-same-layout, and free of path
/// separators so it survives a URL segment. FNV-1a is enough here: the input
/// space is a handful of local directories, and a collision only means two
/// projects would fight over one id — not a security boundary.
pub fn project_id_for_path(path: &str) -> String {
    const OFFSET: u64 = 0xcbf2_9ce4_8422_2325;
    const PRIME: u64 = 0x0000_0100_0000_01b3;

    let mut hash = OFFSET;
    for byte in path.as_bytes() {
        hash ^= u64::from(*byte);
        hash = hash.wrapping_mul(PRIME);
    }
    format!("{hash:016x}")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn project_id_is_stable_and_path_free() {
        let id = project_id_for_path("/Users/ada/Projects/mobile-app");
        assert_eq!(id, project_id_for_path("/Users/ada/Projects/mobile-app"));
        assert_eq!(id.len(), 16);
        assert!(id.chars().all(|c| c.is_ascii_hexdigit()));
    }

    #[test]
    fn project_id_differs_per_path() {
        assert_ne!(project_id_for_path("/a"), project_id_for_path("/b"));
    }

    #[test]
    fn platform_round_trips_through_wire_form() {
        for platform in Platform::ALL {
            assert_eq!(Platform::parse(platform.as_str()), Some(platform));
        }
        assert_eq!(Platform::parse("solaris"), None);
    }

    #[test]
    fn project_serializes_in_camel_case() {
        let project = Project {
            id: "abc".into(),
            name: "Mobile App".into(),
            path: Some("/tmp/app".into()),
            repo: None,
            platforms: vec![Platform::Android, Platform::Ios],
            has_fastforge_config: true,
            created_at: "2026-07-29T00:00:00Z".into(),
            updated_at: "2026-07-29T00:00:00Z".into(),
        };
        let value = serde_json::to_value(&project).unwrap();
        assert_eq!(value["hasFastforgeConfig"], serde_json::json!(true));
        assert_eq!(value["platforms"], serde_json::json!(["android", "ios"]));
        assert!(value.get("repo").is_none(), "None fields stay off the wire");
    }
}
