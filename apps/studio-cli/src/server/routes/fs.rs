use std::path::PathBuf;

use axum::extract::{Query, State};
use serde::{Deserialize, Serialize};
use studio_core::api::ApiError;

use crate::local::{paths, project};
use crate::server::error::{Result, ok};
use crate::server::state::AppState;

#[derive(Debug, Deserialize)]
pub struct BrowseQuery {
    path: Option<String>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct DirectoryEntry {
    pub name: String,
    pub path: String,
    /// Whether registering this directory would produce something useful.
    pub is_project: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct DirectoryListing {
    pub path: String,
    /// Absent at the top of the browsable area, so the client knows not to
    /// offer "up".
    #[serde(skip_serializing_if = "Option::is_none")]
    pub parent: Option<String>,
    pub entries: Vec<DirectoryEntry>,
}

/// Lists directories so the "add project" dialog can offer a picker.
///
/// A browser cannot hand back a real path, so the server has to do the walking.
/// That makes this the most sensitive endpoint here, and it is fenced
/// accordingly: only directories, never file contents, and never outside the
/// user's home. Hidden directories are skipped — nobody is looking for
/// `.ssh` in a project picker, and listing it serves no one.
pub async fn browse(State(state): State<AppState>, Query(query): Query<BrowseQuery>) -> Result {
    let home = paths::canonicalize(state.home())
        .map_err(|error| ApiError::internal("HOME_UNREADABLE", error.to_string()))?;

    let requested = match query.path.as_deref().map(str::trim) {
        Some(path) if !path.is_empty() => PathBuf::from(path),
        _ => home.clone(),
    };

    let path = paths::canonicalize(&requested).map_err(|_| {
        ApiError::not_found(
            "PATH_NOT_FOUND",
            format!("{} does not exist", requested.display()),
        )
    })?;

    // Canonicalised on both sides, so a symlink pointing out of home is caught
    // here rather than followed.
    if !paths::is_within(&home, &path) {
        return Err(ApiError::forbidden(
            "PATH_OUT_OF_BOUNDS",
            "Only directories inside your home directory can be browsed",
        )
        .into());
    }
    if !path.is_dir() {
        return Err(
            ApiError::bad_request("PATH_NOT_A_DIRECTORY", "`path` must be a directory").into(),
        );
    }

    let mut entries: Vec<DirectoryEntry> = std::fs::read_dir(&path)
        .map_err(|error| {
            ApiError::internal(
                "PATH_UNREADABLE",
                format!("Failed to read {}: {error}", path.display()),
            )
        })?
        .flatten()
        .filter(|entry| entry.file_type().is_ok_and(|kind| kind.is_dir()))
        .filter_map(|entry| {
            let name = entry.file_name().to_string_lossy().into_owned();
            if name.starts_with('.') {
                return None;
            }
            Some(DirectoryEntry {
                is_project: project::looks_like_project(&entry.path()),
                path: entry.path().to_string_lossy().into_owned(),
                name,
            })
        })
        .collect();
    entries.sort_by(|left, right| left.name.cmp(&right.name));

    Ok(ok(DirectoryListing {
        parent: (path != home)
            .then(|| {
                path.parent()
                    .map(|parent| parent.to_string_lossy().into_owned())
            })
            .flatten(),
        path: path.to_string_lossy().into_owned(),
        entries,
    }))
}
