use std::path::{Path, PathBuf};

use studio_core::api::ApiError;
use studio_core::config::FastforgeConfig;

pub fn config_path(project: &Path) -> PathBuf {
    project.join(".fastforge").join("config.yaml")
}

/// Reads `.fastforge/config.yaml`, treating a missing file as an empty config.
///
/// A project without one is not an error — it is a project that has not
/// configured any stores yet, which the stores page renders as an empty state.
/// A *malformed* one is an error, and the message names the file so the user
/// knows what to open.
pub fn load(project: &Path) -> Result<FastforgeConfig, ApiError> {
    let path = config_path(project);
    let content = match std::fs::read_to_string(&path) {
        Ok(content) => content,
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => {
            return Ok(FastforgeConfig::default());
        }
        Err(error) => {
            return Err(ApiError::internal(
                "CONFIG_READ_FAILED",
                format!("Failed to read {}: {error}", path.display()),
            ));
        }
    };

    FastforgeConfig::parse(&content).map_err(|error| {
        ApiError::bad_request(
            "CONFIG_INVALID",
            format!("{} is not valid YAML: {error}", path.display()),
        )
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    fn project_with(config: Option<&str>) -> TempDir {
        let temp = TempDir::new().unwrap();
        if let Some(config) = config {
            let path = config_path(temp.path());
            std::fs::create_dir_all(path.parent().unwrap()).unwrap();
            std::fs::write(path, config).unwrap();
        }
        temp
    }

    #[test]
    fn a_project_without_a_config_reads_as_empty() {
        let temp = project_with(None);
        assert!(load(temp.path()).unwrap().stores.is_empty());
    }

    #[test]
    fn a_configured_project_parses() {
        let temp = project_with(Some(
            "stores:\n  appstore:\n    apps:\n      - bundle_id: com.example.app\n",
        ));
        let config = load(temp.path()).unwrap();
        assert_eq!(config.stores.appstore.unwrap().apps.len(), 1);
    }

    #[test]
    fn a_malformed_config_names_the_file_it_could_not_read() {
        let temp = project_with(Some("stores:\n  appstore: [unclosed\n"));
        let error = load(temp.path()).unwrap_err();
        assert_eq!(error.code, "CONFIG_INVALID");
        assert_eq!(error.status, 400);
        assert!(error.message.contains("config.yaml"));
    }
}
