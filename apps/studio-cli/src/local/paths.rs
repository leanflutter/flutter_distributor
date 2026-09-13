use std::path::{Path, PathBuf};

use anyhow::{Context, Result};

/// Overrides where Studio keeps its state. Set by tests and by anyone running
/// a second Studio without disturbing the first.
pub const DATA_DIR_ENV: &str = "FASTFORGE_STUDIO_DATA_DIR";

/// Studio's own state, kept beside fastforge's rather than in a Studio-specific
/// location: they belong to the same tool from the user's point of view.
pub fn data_dir() -> Result<PathBuf> {
    if let Some(override_dir) = std::env::var_os(DATA_DIR_ENV)
        && !override_dir.is_empty()
    {
        return Ok(PathBuf::from(override_dir));
    }
    Ok(home_dir()?.join(".fastforge").join("studio"))
}

pub fn registry_path() -> Result<PathBuf> {
    Ok(data_dir()?.join("projects.json"))
}

pub fn home_dir() -> Result<PathBuf> {
    dirs::home_dir().context("could not determine the home directory")
}

/// Resolves a user-supplied path to an absolute, symlink-free one.
///
/// Every path that arrives over HTTP goes through here before it is used, so
/// containment checks compare canonical paths rather than strings — `..` and
/// symlinks are resolved away first.
pub fn canonicalize(path: &Path) -> Result<PathBuf> {
    path.canonicalize()
        .with_context(|| format!("{} does not exist", path.display()))
}

/// Whether `candidate` is inside `root`, both already canonical.
pub fn is_within(root: &Path, candidate: &Path) -> bool {
    candidate == root || candidate.starts_with(root)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn containment_accepts_the_root_itself_and_descendants() {
        let root = Path::new("/Users/ada/Projects");
        assert!(is_within(root, Path::new("/Users/ada/Projects")));
        assert!(is_within(root, Path::new("/Users/ada/Projects/app/lib")));
    }

    #[test]
    fn containment_rejects_siblings_and_prefix_lookalikes() {
        let root = Path::new("/Users/ada/Projects");
        assert!(!is_within(root, Path::new("/Users/ada")));
        assert!(!is_within(root, Path::new("/Users/ada/Projects-private")));
        assert!(!is_within(root, Path::new("/etc/passwd")));
    }
}
