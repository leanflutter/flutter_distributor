use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use studio_core::model::project_id_for_path;

use super::now_rfc3339;

/// Bumped when the on-disk shape changes in a way older readers cannot handle.
const VERSION: u32 = 1;

/// Studio's list of local projects.
///
/// This is Studio's own state, not the user's: it records which checkouts to
/// show, and nothing about what is inside them. Everything else is read from
/// the checkout itself on every request, so the registry can never go stale
/// against `.fastforge/`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Registry {
    pub version: u32,
    #[serde(default)]
    pub projects: Vec<RegisteredProject>,
}

impl Default for Registry {
    fn default() -> Self {
        Self {
            version: VERSION,
            projects: Vec::new(),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RegisteredProject {
    pub id: String,
    /// User-facing, and editable — it starts as whatever detection found.
    pub name: String,
    pub path: PathBuf,
    pub created_at: String,
    pub updated_at: String,
}

impl Registry {
    /// Reads the registry, treating "not there yet" as "empty".
    ///
    /// A corrupt file is an error rather than a silent reset: losing the list
    /// of projects is annoying enough that it should be visible.
    pub fn load(path: &Path) -> Result<Self> {
        match std::fs::read_to_string(path) {
            Ok(content) if content.trim().is_empty() => Ok(Self::default()),
            Ok(content) => serde_json::from_str(&content)
                .with_context(|| format!("failed to parse {}", path.display())),
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => Ok(Self::default()),
            Err(error) => Err(error).with_context(|| format!("failed to read {}", path.display())),
        }
    }

    /// Writes through a temporary file so an interrupted save cannot leave a
    /// half-written registry behind.
    pub fn save(&self, path: &Path) -> Result<()> {
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)
                .with_context(|| format!("failed to create {}", parent.display()))?;
        }
        let content = serde_json::to_string_pretty(self)?;
        let temporary = path.with_extension("json.tmp");
        std::fs::write(&temporary, content)
            .with_context(|| format!("failed to write {}", temporary.display()))?;
        std::fs::rename(&temporary, path)
            .with_context(|| format!("failed to replace {}", path.display()))?;
        Ok(())
    }

    pub fn get(&self, id: &str) -> Option<&RegisteredProject> {
        self.projects.iter().find(|project| project.id == id)
    }

    pub fn get_mut(&mut self, id: &str) -> Option<&mut RegisteredProject> {
        self.projects.iter_mut().find(|project| project.id == id)
    }

    pub fn find_by_path(&self, path: &Path) -> Option<&RegisteredProject> {
        self.projects.iter().find(|project| project.path == path)
    }

    /// Registers a canonical path. The id is derived from the path, so
    /// registering the same directory twice is a conflict rather than a
    /// duplicate.
    pub fn add(&mut self, path: PathBuf, name: String) -> RegisteredProject {
        let now = now_rfc3339();
        let project = RegisteredProject {
            id: project_id_for_path(&path.to_string_lossy()),
            name,
            path,
            created_at: now.clone(),
            updated_at: now,
        };
        self.projects.push(project.clone());
        project
    }

    /// Returns whether anything was removed, so the caller can answer 404.
    pub fn remove(&mut self, id: &str) -> bool {
        let before = self.projects.len();
        self.projects.retain(|project| project.id != id);
        self.projects.len() != before
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn a_missing_registry_reads_as_empty() {
        let temp = TempDir::new().unwrap();
        let registry = Registry::load(&temp.path().join("projects.json")).unwrap();
        assert!(registry.projects.is_empty());
        assert_eq!(registry.version, VERSION);
    }

    #[test]
    fn an_empty_file_reads_as_empty() {
        let temp = TempDir::new().unwrap();
        let path = temp.path().join("projects.json");
        std::fs::write(&path, "  \n").unwrap();
        assert!(Registry::load(&path).unwrap().projects.is_empty());
    }

    #[test]
    fn a_corrupt_registry_is_an_error_rather_than_a_silent_reset() {
        let temp = TempDir::new().unwrap();
        let path = temp.path().join("projects.json");
        std::fs::write(&path, "{ not json").unwrap();
        assert!(Registry::load(&path).is_err());
    }

    #[test]
    fn saving_creates_the_directory_and_round_trips() {
        let temp = TempDir::new().unwrap();
        let path = temp.path().join("nested").join("projects.json");

        let mut registry = Registry::default();
        let added = registry.add(PathBuf::from("/Users/ada/app"), "app".into());
        registry.save(&path).unwrap();

        let reloaded = Registry::load(&path).unwrap();
        assert_eq!(reloaded.projects, std::slice::from_ref(&added));
        assert_eq!(reloaded.get(&added.id).unwrap().name, "app");
    }

    #[test]
    fn saving_leaves_no_temporary_file_behind() {
        let temp = TempDir::new().unwrap();
        let path = temp.path().join("projects.json");
        Registry::default().save(&path).unwrap();
        assert!(!path.with_extension("json.tmp").exists());
    }

    #[test]
    fn ids_come_from_the_path_so_the_same_checkout_is_the_same_project() {
        let mut registry = Registry::default();
        let first = registry.add(PathBuf::from("/Users/ada/app"), "app".into());
        let mut other = Registry::default();
        let second = other.add(PathBuf::from("/Users/ada/app"), "renamed".into());
        assert_eq!(first.id, second.id);
    }

    #[test]
    fn removal_reports_whether_it_matched() {
        let mut registry = Registry::default();
        let project = registry.add(PathBuf::from("/Users/ada/app"), "app".into());
        assert!(registry.remove(&project.id));
        assert!(!registry.remove(&project.id));
        assert!(registry.projects.is_empty());
    }

    #[test]
    fn lookup_by_path_finds_an_existing_registration() {
        let mut registry = Registry::default();
        registry.add(PathBuf::from("/Users/ada/app"), "app".into());
        assert!(registry.find_by_path(Path::new("/Users/ada/app")).is_some());
        assert!(
            registry
                .find_by_path(Path::new("/Users/ada/other"))
                .is_none()
        );
    }
}
