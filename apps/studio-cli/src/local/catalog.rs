use std::path::{Path, PathBuf};

use sha2::{Digest, Sha256};
use studio_core::api::ApiError;
use studio_core::model::{
    CATALOG_MANIFEST, CatalogEntry, CatalogEntryKind, CatalogFile, CatalogState, CatalogTree,
    StoreKind, catalog_dir, is_safe_relative_path,
};

use super::rfc3339;

/// Depth limit for the tree walk. The real layout bottoms out at
/// `versions/<platform>/<version>/<locale>/screenshots/<file>` — six levels —
/// so this only ever trips on a symlink loop or a catalog that is not one.
const MAX_DEPTH: usize = 12;

pub fn catalog_path(project: &Path, store: StoreKind, identifier: &str) -> PathBuf {
    project.join(catalog_dir(store, identifier))
}

/// Summarises a catalog without reading any of it.
pub fn state(project: &Path, store: StoreKind, identifier: &str) -> CatalogState {
    let root = catalog_path(project, store, identifier);
    let mut state = CatalogState::empty(store, identifier);

    if !root.is_dir() {
        return state;
    }
    state.exists = true;
    state.file_count = count_files(&root, 0);
    state.last_pulled_at = std::fs::metadata(root.join(CATALOG_MANIFEST))
        .and_then(|metadata| metadata.modified())
        .ok()
        .map(rfc3339);
    state
}

fn count_files(dir: &Path, depth: usize) -> usize {
    if depth >= MAX_DEPTH {
        return 0;
    }
    let Ok(entries) = std::fs::read_dir(dir) else {
        return 0;
    };
    entries
        .flatten()
        .map(|entry| match entry.file_type() {
            Ok(kind) if kind.is_dir() => count_files(&entry.path(), depth + 1),
            Ok(kind) if kind.is_file() => 1,
            // Symlinks are not followed: a catalog is written by pull, and
            // anything else in there is not ours to walk.
            _ => 0,
        })
        .sum()
}

/// Walks the whole catalog in one pass.
pub fn tree(project: &Path, store: StoreKind, identifier: &str) -> CatalogTree {
    let root = catalog_path(project, store, identifier);
    let relative_root = catalog_dir(store, identifier);

    if !root.is_dir() {
        return CatalogTree {
            root: relative_root,
            exists: false,
            entries: Vec::new(),
        };
    }

    CatalogTree {
        root: relative_root,
        exists: true,
        entries: read_entries(&root, "", 0),
    }
}

fn read_entries(dir: &Path, prefix: &str, depth: usize) -> Vec<CatalogEntry> {
    if depth >= MAX_DEPTH {
        return Vec::new();
    }
    let Ok(read_dir) = std::fs::read_dir(dir) else {
        return Vec::new();
    };

    let mut entries: Vec<CatalogEntry> = read_dir
        .flatten()
        .filter_map(|entry| {
            let name = entry.file_name().to_string_lossy().into_owned();
            let path = if prefix.is_empty() {
                name.clone()
            } else {
                format!("{prefix}/{name}")
            };
            let file_type = entry.file_type().ok()?;

            if file_type.is_dir() {
                Some(CatalogEntry {
                    children: read_entries(&entry.path(), &path, depth + 1),
                    path,
                    name,
                    kind: CatalogEntryKind::Dir,
                    size: None,
                    modified_at: None,
                })
            } else if file_type.is_file() {
                let metadata = entry.metadata().ok();
                Some(CatalogEntry {
                    kind: CatalogEntryKind::for_path(&name),
                    size: metadata.as_ref().map(|metadata| metadata.len()),
                    modified_at: metadata
                        .as_ref()
                        .and_then(|metadata| metadata.modified().ok())
                        .map(rfc3339),
                    path,
                    name,
                    children: Vec::new(),
                })
            } else {
                None
            }
        })
        .collect();

    // Directories first, then files, each alphabetically — `read_dir` order is
    // whatever the filesystem feels like, and a tree that reshuffles between
    // requests is unreadable.
    entries.sort_by(|left, right| {
        let left_is_dir = left.kind == CatalogEntryKind::Dir;
        let right_is_dir = right.kind == CatalogEntryKind::Dir;
        right_is_dir
            .cmp(&left_is_dir)
            .then_with(|| left.name.cmp(&right.name))
    });
    entries
}

/// Resolves a request path against the catalog directory.
///
/// Two checks, both needed: the syntactic one rejects `..` before it reaches
/// the filesystem, and the canonical one catches a symlink inside the catalog
/// that points out of it.
fn resolve(
    project: &Path,
    store: StoreKind,
    identifier: &str,
    relative: &str,
) -> Result<PathBuf, ApiError> {
    if !is_safe_relative_path(relative) {
        return Err(ApiError::bad_request(
            "INVALID_PATH",
            "`path` must stay inside the catalog directory",
        ));
    }

    let root = catalog_path(project, store, identifier);
    let root = root.canonicalize().map_err(|_| {
        ApiError::not_found(
            "CATALOG_NOT_FOUND",
            "This app's catalog has not been pulled yet",
        )
    })?;

    let target = root.join(relative).canonicalize().map_err(|_| {
        ApiError::not_found(
            "CATALOG_FILE_NOT_FOUND",
            format!("No such file: {relative}"),
        )
    })?;

    if !super::paths::is_within(&root, &target) {
        return Err(ApiError::bad_request(
            "INVALID_PATH",
            "`path` must stay inside the catalog directory",
        ));
    }
    Ok(target)
}

/// Rejects an unsafe path before anything else looks at it.
///
/// Ordered ahead of the file-kind check on purpose: `../../etc/passwd` should
/// read as a rejected path, not as "that is not a YAML file".
fn text_kind(relative: &str) -> Result<CatalogEntryKind, ApiError> {
    if !is_safe_relative_path(relative) {
        return Err(ApiError::bad_request(
            "INVALID_PATH",
            "`path` must stay inside the catalog directory",
        ));
    }

    let kind = CatalogEntryKind::for_path(relative);
    if !kind.is_text() {
        return Err(ApiError::bad_request(
            "NOT_A_TEXT_FILE",
            format!("{relative} is not a text file — fetch it through `catalog/raw`"),
        ));
    }
    Ok(kind)
}

/// Reads one text file out of the catalog.
pub fn read_file(
    project: &Path,
    store: StoreKind,
    identifier: &str,
    relative: &str,
) -> Result<CatalogFile, ApiError> {
    let kind = text_kind(relative)?;
    let path = resolve(project, store, identifier, relative)?;
    let content = std::fs::read_to_string(&path).map_err(|error| {
        ApiError::internal(
            "CATALOG_READ_FAILED",
            format!("Failed to read {relative}: {error}"),
        )
    })?;

    Ok(CatalogFile {
        etag: etag(&content),
        path: relative.to_owned(),
        kind,
        content,
    })
}

/// Reads a screenshot or preview as bytes.
pub fn read_bytes(
    project: &Path,
    store: StoreKind,
    identifier: &str,
    relative: &str,
) -> Result<(Vec<u8>, &'static str), ApiError> {
    let path = resolve(project, store, identifier, relative)?;
    let bytes = std::fs::read(&path).map_err(|error| {
        ApiError::internal(
            "CATALOG_READ_FAILED",
            format!("Failed to read {relative}: {error}"),
        )
    })?;
    Ok((bytes, content_type(relative)))
}

/// Writes one text file back.
///
/// When `expected_etag` is supplied and no longer matches, the write is
/// refused: the likely cause is a `pull` that refreshed the catalog while an
/// editor tab was open, and silently overwriting it would throw away what the
/// store actually holds.
pub fn write_file(
    project: &Path,
    store: StoreKind,
    identifier: &str,
    relative: &str,
    content: &str,
    expected_etag: Option<&str>,
) -> Result<CatalogFile, ApiError> {
    let kind = text_kind(relative)?;

    // Only existing files are writable. Creating new catalog entries is what
    // `pull` is for; inventing one here would produce something push cannot
    // map back to the store.
    let path = resolve(project, store, identifier, relative)?;

    if let Some(expected) = expected_etag {
        let current = std::fs::read_to_string(&path).map_err(|error| {
            ApiError::internal(
                "CATALOG_READ_FAILED",
                format!("Failed to read {relative}: {error}"),
            )
        })?;
        if etag(&current) != expected {
            return Err(ApiError::conflict(
                "CATALOG_FILE_STALE",
                format!("{relative} changed since it was read — reload before saving"),
            ));
        }
    }

    std::fs::write(&path, content).map_err(|error| {
        ApiError::internal(
            "CATALOG_WRITE_FAILED",
            format!("Failed to write {relative}: {error}"),
        )
    })?;

    Ok(CatalogFile {
        etag: etag(content),
        path: relative.to_owned(),
        kind,
        content: content.to_owned(),
    })
}

/// Content hash, not a revision counter: two writers who happen to produce the
/// same bytes do not conflict, which is the behaviour you want when a save
/// button is pressed twice.
fn etag(content: &str) -> String {
    let digest = Sha256::digest(content.as_bytes());
    format!("{digest:x}")[..32].to_owned()
}

fn content_type(path: &str) -> &'static str {
    match path
        .rsplit_once('.')
        .map(|(_, ext)| ext.to_ascii_lowercase())
    {
        Some(ext) => match ext.as_str() {
            "png" => "image/png",
            "jpg" | "jpeg" => "image/jpeg",
            "webp" => "image/webp",
            "gif" => "image/gif",
            "mp4" => "video/mp4",
            "mov" => "video/quicktime",
            "m4v" => "video/x-m4v",
            _ => "application/octet-stream",
        },
        None => "application/octet-stream",
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    /// A catalog shaped like the one `fastforge appstore catalog pull` writes.
    fn catalog() -> TempDir {
        let temp = TempDir::new().unwrap();
        let root = catalog_path(temp.path(), StoreKind::AppStore, "com.example.myapp");
        for dir in [
            "info",
            "versions/IOS/1.0.0/en-US/screenshots",
            "versions/IOS/1.0.0/en-US/previews",
        ] {
            std::fs::create_dir_all(root.join(dir)).unwrap();
        }
        for (path, content) in [
            ("app.yaml", "bundleId: com.example.myapp\n"),
            ("app_info.yaml", "primaryCategory: GAMES\n"),
            (".manifest.yaml", "screenshots: []\n"),
            ("info/en-US.yaml", "name: My App\n"),
            ("versions/IOS/1.0.0/version.yaml", "copyright: 2026\n"),
            (
                "versions/IOS/1.0.0/en-US/localization.yaml",
                "whatsNew: Bug fixes\n",
            ),
        ] {
            std::fs::write(root.join(path), content).unwrap();
        }
        std::fs::write(
            root.join("versions/IOS/1.0.0/en-US/screenshots/01.png"),
            [0x89, 0x50, 0x4e, 0x47],
        )
        .unwrap();
        temp
    }

    #[test]
    fn an_unpulled_catalog_reports_its_future_path() {
        let temp = TempDir::new().unwrap();
        let state = state(temp.path(), StoreKind::AppStore, "com.example.myapp");
        assert!(!state.exists);
        assert_eq!(state.file_count, 0);
        assert_eq!(state.path, ".fastforge/stores/appstore/com.example.myapp");
        assert!(state.last_pulled_at.is_none());
    }

    #[test]
    fn a_pulled_catalog_reports_its_size_and_pull_time() {
        let temp = catalog();
        let state = state(temp.path(), StoreKind::AppStore, "com.example.myapp");
        assert!(state.exists);
        assert_eq!(state.file_count, 7);
        assert!(state.last_pulled_at.is_some(), "read from .manifest.yaml");
    }

    #[test]
    fn the_tree_puts_directories_first_and_sorts_by_name() {
        let temp = catalog();
        let tree = tree(temp.path(), StoreKind::AppStore, "com.example.myapp");
        assert!(tree.exists);
        let names: Vec<&str> = tree.entries.iter().map(|e| e.name.as_str()).collect();
        assert_eq!(
            names,
            [
                "info",
                "versions",
                ".manifest.yaml",
                "app.yaml",
                "app_info.yaml"
            ]
        );
    }

    #[test]
    fn the_tree_carries_children_and_project_relative_paths() {
        let temp = catalog();
        let tree = tree(temp.path(), StoreKind::AppStore, "com.example.myapp");
        let versions = tree
            .entries
            .iter()
            .find(|entry| entry.name == "versions")
            .unwrap();
        let ios = &versions.children[0];
        assert_eq!(ios.path, "versions/IOS");

        let child = |entry: &CatalogEntry, name: &str| {
            entry
                .children
                .iter()
                .find(|child| child.name == name)
                .unwrap_or_else(|| panic!("{name} should be under {}", entry.path))
                .clone()
        };
        let locale = child(&child(ios, "1.0.0"), "en-US");
        let localization = child(&locale, "localization.yaml");

        assert_eq!(
            localization.path,
            "versions/IOS/1.0.0/en-US/localization.yaml"
        );
        assert_eq!(localization.kind, CatalogEntryKind::Yaml);
        assert!(localization.size.unwrap() > 0);
        // Directories sort ahead of files at every level, not just the root.
        let names: Vec<&str> = locale.children.iter().map(|e| e.name.as_str()).collect();
        assert_eq!(names, ["previews", "screenshots", "localization.yaml"]);
    }

    #[test]
    fn a_missing_catalog_yields_an_empty_tree_rather_than_an_error() {
        let temp = TempDir::new().unwrap();
        let tree = tree(temp.path(), StoreKind::GooglePlay, "com.example.myapp");
        assert!(!tree.exists);
        assert!(tree.entries.is_empty());
        assert_eq!(tree.root, ".fastforge/stores/googleplay/com.example.myapp");
    }

    #[test]
    fn reading_a_file_returns_its_content_and_etag() {
        let temp = catalog();
        let file = read_file(
            temp.path(),
            StoreKind::AppStore,
            "com.example.myapp",
            "versions/IOS/1.0.0/en-US/localization.yaml",
        )
        .unwrap();
        assert_eq!(file.content, "whatsNew: Bug fixes\n");
        assert_eq!(file.kind, CatalogEntryKind::Yaml);
        assert_eq!(file.etag.len(), 32);
    }

    #[test]
    fn binary_files_are_refused_by_the_text_endpoint() {
        let temp = catalog();
        let error = read_file(
            temp.path(),
            StoreKind::AppStore,
            "com.example.myapp",
            "versions/IOS/1.0.0/en-US/screenshots/01.png",
        )
        .unwrap_err();
        assert_eq!(error.code, "NOT_A_TEXT_FILE");
    }

    #[test]
    fn images_come_back_with_a_usable_content_type() {
        let temp = catalog();
        let (bytes, content_type) = read_bytes(
            temp.path(),
            StoreKind::AppStore,
            "com.example.myapp",
            "versions/IOS/1.0.0/en-US/screenshots/01.png",
        )
        .unwrap();
        assert_eq!(content_type, "image/png");
        assert_eq!(bytes, [0x89, 0x50, 0x4e, 0x47]);
    }

    #[test]
    fn traversal_is_refused_before_it_reaches_the_filesystem() {
        let temp = catalog();
        for path in ["../../../../etc/passwd", "/etc/passwd", "..", "a\\b"] {
            let error =
                read_file(temp.path(), StoreKind::AppStore, "com.example.myapp", path).unwrap_err();
            assert_eq!(error.code, "INVALID_PATH", "{path} should be refused");
        }
    }

    #[test]
    #[cfg(unix)]
    fn a_symlink_out_of_the_catalog_is_refused() {
        let temp = catalog();
        let outside = temp.path().join("secret.yaml");
        std::fs::write(&outside, "token: hunter2\n").unwrap();
        let root = catalog_path(temp.path(), StoreKind::AppStore, "com.example.myapp");
        std::os::unix::fs::symlink(&outside, root.join("escape.yaml")).unwrap();

        let error = read_file(
            temp.path(),
            StoreKind::AppStore,
            "com.example.myapp",
            "escape.yaml",
        )
        .unwrap_err();
        assert_eq!(error.code, "INVALID_PATH");
    }

    #[test]
    fn a_missing_file_is_a_404() {
        let temp = catalog();
        let error = read_file(
            temp.path(),
            StoreKind::AppStore,
            "com.example.myapp",
            "info/fr-FR.yaml",
        )
        .unwrap_err();
        assert_eq!(error.status, 404);
        assert_eq!(error.code, "CATALOG_FILE_NOT_FOUND");
    }

    #[test]
    fn writing_with_a_matching_etag_succeeds_and_returns_the_new_one() {
        let temp = catalog();
        let before = read_file(
            temp.path(),
            StoreKind::AppStore,
            "com.example.myapp",
            "info/en-US.yaml",
        )
        .unwrap();

        let after = write_file(
            temp.path(),
            StoreKind::AppStore,
            "com.example.myapp",
            "info/en-US.yaml",
            "name: Renamed App\n",
            Some(&before.etag),
        )
        .unwrap();

        assert_ne!(after.etag, before.etag);
        assert_eq!(
            std::fs::read_to_string(
                catalog_path(temp.path(), StoreKind::AppStore, "com.example.myapp")
                    .join("info/en-US.yaml")
            )
            .unwrap(),
            "name: Renamed App\n"
        );
    }

    #[test]
    fn writing_with_a_stale_etag_is_refused_and_changes_nothing() {
        let temp = catalog();
        let error = write_file(
            temp.path(),
            StoreKind::AppStore,
            "com.example.myapp",
            "info/en-US.yaml",
            "name: Clobbered\n",
            Some("0000000000000000000000000000000"),
        )
        .unwrap_err();

        assert_eq!(error.status, 409);
        assert_eq!(error.code, "CATALOG_FILE_STALE");
        let unchanged = read_file(
            temp.path(),
            StoreKind::AppStore,
            "com.example.myapp",
            "info/en-US.yaml",
        )
        .unwrap();
        assert_eq!(unchanged.content, "name: My App\n");
    }

    #[test]
    fn writing_without_an_etag_is_unconditional() {
        let temp = catalog();
        assert!(
            write_file(
                temp.path(),
                StoreKind::AppStore,
                "com.example.myapp",
                "info/en-US.yaml",
                "name: Forced\n",
                None,
            )
            .is_ok()
        );
    }

    #[test]
    fn writing_a_file_that_does_not_exist_is_a_404() {
        let temp = catalog();
        let error = write_file(
            temp.path(),
            StoreKind::AppStore,
            "com.example.myapp",
            "info/de-DE.yaml",
            "name: Neu\n",
            None,
        )
        .unwrap_err();
        assert_eq!(error.code, "CATALOG_FILE_NOT_FOUND");
    }
}
