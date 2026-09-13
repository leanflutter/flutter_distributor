use serde::{Deserialize, Serialize};

use super::store::StoreKind;

/// Root of the catalog tree inside a project, matching what
/// `fastforge store catalog pull` writes.
pub const CATALOG_ROOT: &str = ".fastforge/stores";

/// Where one store app's catalog lives, relative to the project root.
///
/// Layout (App Store):
/// ```text
/// <bundle-id>/
/// ├── app.yaml
/// ├── app_info.yaml
/// ├── info/<locale>.yaml
/// ├── versions/<platform>/<version>/
/// │   ├── version.yaml
/// │   └── <locale>/{localization.yaml,screenshots/,previews/}
/// └── .manifest.yaml
/// ```
/// Google Play uses `app.yaml`, `listings/`, `screenshots/<lang>/`, `tracks/`.
pub fn catalog_dir(store: StoreKind, identifier: &str) -> String {
    format!("{CATALOG_ROOT}/{}/{}", store.as_str(), identifier)
}

/// Written by pull, read by push to detect remote screenshot ids and local
/// edits. Studio treats it as machine-owned and hides it from the editor.
pub const CATALOG_MANIFEST: &str = ".manifest.yaml";

/// Summary of a store app's local catalog, shown before anyone opens it.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CatalogState {
    /// Project-relative directory.
    pub path: String,
    pub exists: bool,
    /// Modification time of `.manifest.yaml`, the closest thing to "when did
    /// pull last run". RFC 3339, produced by the host.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub last_pulled_at: Option<String>,
    pub file_count: usize,
}

impl CatalogState {
    /// The state of a catalog that has never been pulled.
    pub fn empty(store: StoreKind, identifier: &str) -> Self {
        Self {
            path: catalog_dir(store, identifier),
            exists: false,
            last_pulled_at: None,
            file_count: 0,
        }
    }
}

/// How the editor should treat a catalog file.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum CatalogEntryKind {
    Dir,
    /// Editable as text.
    Yaml,
    /// Rendered inline, fetched through the `raw` endpoint.
    Image,
    Video,
    Other,
}

impl CatalogEntryKind {
    /// Classifies by extension. Deliberately does not sniff content: catalog
    /// files come from fastforge's own writer, so the extension is truthful.
    pub fn for_path(path: &str) -> CatalogEntryKind {
        let extension = path
            .rsplit_once('.')
            .map(|(_, extension)| extension.to_ascii_lowercase())
            .unwrap_or_default();
        match extension.as_str() {
            "yaml" | "yml" => CatalogEntryKind::Yaml,
            "png" | "jpg" | "jpeg" | "webp" | "gif" => CatalogEntryKind::Image,
            "mp4" | "mov" | "m4v" => CatalogEntryKind::Video,
            _ => CatalogEntryKind::Other,
        }
    }

    pub fn is_text(self) -> bool {
        matches!(self, CatalogEntryKind::Yaml)
    }
}

/// One node of the catalog tree. Directories carry their children inline: a
/// catalog is a few hundred files at most, and the UI wants the whole shape at
/// once to render a tree without a request per expand.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CatalogEntry {
    /// Path relative to the catalog directory.
    pub path: String,
    pub name: String,
    pub kind: CatalogEntryKind,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub size: Option<u64>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub modified_at: Option<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub children: Vec<CatalogEntry>,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CatalogTree {
    /// Project-relative catalog root.
    pub root: String,
    pub exists: bool,
    pub entries: Vec<CatalogEntry>,
}

/// A single text file, with the tag needed to write it back safely.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CatalogFile {
    pub path: String,
    pub kind: CatalogEntryKind,
    pub content: String,
    /// Content hash. `PUT` echoes it back so a stale editor tab cannot
    /// overwrite a catalog that `pull` refreshed in the meantime.
    pub etag: String,
}

/// Rejects paths that would escape the catalog directory.
///
/// The host resolves these against a real directory, so this is the one place
/// that has to be strict: no absolute paths, no `..`, no backslashes (a
/// Windows-shaped path would sidestep a `/`-only check), no leading `/`.
pub fn is_safe_relative_path(path: &str) -> bool {
    if path.is_empty() || path.starts_with('/') || path.contains('\\') || path.contains('\0') {
        return false;
    }
    // A Windows drive prefix such as `C:` never appears in a catalog path.
    if path.len() >= 2 && path.as_bytes()[1] == b':' {
        return false;
    }
    path.split('/')
        .all(|segment| !segment.is_empty() && segment != "." && segment != "..")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn catalog_dir_matches_the_documented_layout() {
        assert_eq!(
            catalog_dir(StoreKind::AppStore, "com.example.myapp"),
            ".fastforge/stores/appstore/com.example.myapp"
        );
        assert_eq!(
            catalog_dir(StoreKind::GooglePlay, "com.example.myapp"),
            ".fastforge/stores/googleplay/com.example.myapp"
        );
    }

    #[test]
    fn entries_are_classified_by_extension() {
        assert_eq!(
            CatalogEntryKind::for_path("versions/IOS/1.0.0/en-US/localization.yaml"),
            CatalogEntryKind::Yaml
        );
        assert_eq!(
            CatalogEntryKind::for_path("screenshots/APP_IPHONE_67/01.PNG"),
            CatalogEntryKind::Image
        );
        assert_eq!(
            CatalogEntryKind::for_path("previews/intro.mov"),
            CatalogEntryKind::Video
        );
        assert_eq!(
            CatalogEntryKind::for_path("README"),
            CatalogEntryKind::Other
        );
    }

    #[test]
    fn safe_paths_accept_real_catalog_files() {
        assert!(is_safe_relative_path("app.yaml"));
        assert!(is_safe_relative_path(
            "versions/IOS/1.0.0/en-US/localization.yaml"
        ));
    }

    #[test]
    fn safe_paths_reject_escapes() {
        for path in [
            "",
            "/etc/passwd",
            "../secrets.yaml",
            "versions/../../..",
            "a//b",
            "C:/Windows",
            "info\\en-US.yaml",
            "app.yaml\0",
        ] {
            assert!(!is_safe_relative_path(path), "{path} should be rejected");
        }
    }
}
