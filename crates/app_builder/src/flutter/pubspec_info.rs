use std::path::Path;

/// Information parsed from a Flutter project's `pubspec.yaml`.
#[derive(Debug, Clone)]
pub struct PubspecInfo {
    pub build_name: String,
    pub build_number: String,
}

impl PubspecInfo {
    /// Reads `version` from `pubspec.yaml` and splits it like Dart's
    /// `AppBuilder`: build name = text before the first `+`, build number =
    /// text after the last `+` (both are the whole version when it has no
    /// `+`). Returns `None` when the file or its `version` is missing.
    pub fn load(path: impl AsRef<Path>) -> Option<Self> {
        let content = std::fs::read_to_string(path).ok()?;
        let yaml: serde_yaml::Value = serde_yaml::from_str(&content).ok()?;
        let version = match yaml.get("version")? {
            serde_yaml::Value::String(s) => s.trim().to_string(),
            serde_yaml::Value::Number(n) => n.to_string(),
            _ => return None,
        };
        if version.is_empty() {
            return None;
        }
        Some(Self::from_version(&version))
    }

    pub fn from_version(version: &str) -> Self {
        Self {
            build_name: version.split('+').next().unwrap_or(version).to_string(),
            build_number: version.rsplit('+').next().unwrap_or(version).to_string(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn splits_version_like_dart() {
        let info = PubspecInfo::from_version("1.2.3+45");
        assert_eq!(info.build_name, "1.2.3");
        assert_eq!(info.build_number, "45");
        let info = PubspecInfo::from_version("1.2.3");
        assert_eq!(info.build_name, "1.2.3");
        assert_eq!(info.build_number, "1.2.3");
    }
}
