use std::path::Path;

use studio_core::model::Platform;

/// What a directory looks like from the outside.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Detected {
    pub name: String,
    pub platforms: Vec<Platform>,
    pub has_fastforge_config: bool,
}

/// Files that mark a directory as something Studio can register.
const PROJECT_MARKERS: [&str; 4] = ["pubspec.yaml", "package.json", "Cargo.toml", ".fastforge"];

/// Reads a checkout without running anything.
///
/// Deliberately shallow: no `flutter`, no `fastforge analyze`, no subprocess.
/// Listing projects must stay instant, and a directory that cannot be analysed
/// (wrong SDK, half-cloned) should still be listable.
pub fn detect(path: &Path) -> Detected {
    Detected {
        name: detect_name(path),
        platforms: detect_platforms(path),
        has_fastforge_config: path.join(".fastforge").join("config.yaml").is_file(),
    }
}

/// Whether a directory is worth offering in the picker.
pub fn looks_like_project(path: &Path) -> bool {
    PROJECT_MARKERS
        .iter()
        .any(|marker| path.join(marker).exists())
}

/// Prefers the project's declared name, falling back to the directory name.
///
/// The declared name is snake_case in Dart and kebab-case in npm, so it is only
/// used when it exists — otherwise the directory name is what the developer
/// actually calls the project.
fn detect_name(path: &Path) -> String {
    if let Some(name) = read_pubspec_name(path) {
        return name;
    }
    if let Some(name) = read_package_json_name(path) {
        return name;
    }
    path.file_name()
        .and_then(|name| name.to_str())
        .unwrap_or("Untitled")
        .to_owned()
}

fn read_pubspec_name(path: &Path) -> Option<String> {
    let content = std::fs::read_to_string(path.join("pubspec.yaml")).ok()?;
    let value: serde_yaml::Value = serde_yaml::from_str(&content).ok()?;
    value
        .get("name")?
        .as_str()
        .map(str::trim)
        .filter(|name| !name.is_empty())
        .map(str::to_owned)
}

fn read_package_json_name(path: &Path) -> Option<String> {
    let content = std::fs::read_to_string(path.join("package.json")).ok()?;
    let value: serde_json::Value = serde_json::from_str(&content).ok()?;
    value
        .get("name")?
        .as_str()
        .map(str::trim)
        .filter(|name| !name.is_empty())
        .map(str::to_owned)
}

/// Platforms are read from the per-platform directories a Flutter (or native)
/// project keeps at its root.
fn detect_platforms(path: &Path) -> Vec<Platform> {
    Platform::ALL
        .into_iter()
        .filter(|platform| path.join(platform.as_str()).is_dir())
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::TempDir;

    fn project(files: &[(&str, &str)], dirs: &[&str]) -> TempDir {
        let temp = TempDir::new().unwrap();
        for dir in dirs {
            fs::create_dir_all(temp.path().join(dir)).unwrap();
        }
        for (path, content) in files {
            let full = temp.path().join(path);
            if let Some(parent) = full.parent() {
                fs::create_dir_all(parent).unwrap();
            }
            fs::write(full, content).unwrap();
        }
        temp
    }

    #[test]
    fn a_flutter_project_reports_its_pubspec_name_and_platform_dirs() {
        let temp = project(
            &[("pubspec.yaml", "name: my_app\nversion: 1.0.0\n")],
            &["android", "ios", "macos"],
        );
        let detected = detect(temp.path());
        assert_eq!(detected.name, "my_app");
        assert_eq!(
            detected.platforms,
            [Platform::Android, Platform::Ios, Platform::Macos]
        );
        assert!(!detected.has_fastforge_config);
    }

    #[test]
    fn a_fastforge_config_is_noticed() {
        let temp = project(&[(".fastforge/config.yaml", "stores: {}\n")], &[]);
        assert!(detect(temp.path()).has_fastforge_config);
    }

    #[test]
    fn a_fastforge_directory_without_a_config_does_not_count() {
        let temp = project(&[], &[".fastforge/workflows"]);
        assert!(!detect(temp.path()).has_fastforge_config);
        // It is still a project worth offering, though.
        assert!(looks_like_project(temp.path()));
    }

    #[test]
    fn the_directory_name_is_the_fallback() {
        let temp = TempDir::new().unwrap();
        let path = temp.path().join("Internal Tools");
        std::fs::create_dir(&path).unwrap();
        assert_eq!(detect(&path).name, "Internal Tools");
    }

    #[test]
    fn a_malformed_pubspec_falls_back_instead_of_failing() {
        let temp = project(&[("pubspec.yaml", "name: [unclosed\n")], &[]);
        let detected = detect(temp.path());
        assert_eq!(
            detected.name,
            temp.path().file_name().unwrap().to_str().unwrap()
        );
    }

    #[test]
    fn npm_projects_are_recognised_too() {
        let temp = project(&[("package.json", r#"{"name":"studio"}"#)], &[]);
        assert_eq!(detect(temp.path()).name, "studio");
        assert!(looks_like_project(temp.path()));
    }

    #[test]
    fn an_ordinary_directory_is_not_a_project() {
        let temp = TempDir::new().unwrap();
        assert!(!looks_like_project(temp.path()));
    }
}
