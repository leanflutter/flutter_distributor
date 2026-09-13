use std::path::PathBuf;

use axum::Json;
use axum::extract::{Path, State};
use axum::response::Response;
use studio_core::api::{
    ApiError, CreateProjectRequest, UpdateProjectRequest, validate_project_name,
};
use studio_core::model::{Project, ProjectSummary};

use crate::local::registry::RegisteredProject;
use crate::local::{now_rfc3339, paths, project};
use crate::server::error::{Result, created, no_content, ok};
use crate::server::state::AppState;

/// Lists what is registered, re-reading each checkout as it goes.
///
/// Detection is deliberately repeated per request rather than cached: a
/// project that gained `.fastforge/config.yaml` or an `ios/` directory since
/// the last look should show up without anyone refreshing anything.
pub async fn list(State(state): State<AppState>) -> Response {
    let projects: Vec<ProjectSummary> = state
        .registry()
        .await
        .projects
        .iter()
        .map(summarize)
        .collect();
    ok(projects)
}

fn summarize(registered: &RegisteredProject) -> ProjectSummary {
    if !registered.path.is_dir() {
        return ProjectSummary {
            id: registered.id.clone(),
            name: registered.name.clone(),
            path: Some(registered.path.to_string_lossy().into_owned()),
            platforms: Vec::new(),
            has_fastforge_config: false,
            missing: true,
        };
    }

    let detected = project::detect(&registered.path);
    ProjectSummary {
        id: registered.id.clone(),
        name: registered.name.clone(),
        path: Some(registered.path.to_string_lossy().into_owned()),
        platforms: detected.platforms,
        has_fastforge_config: detected.has_fastforge_config,
        missing: false,
    }
}

pub async fn get(State(state): State<AppState>, Path(project_id): Path<String>) -> Result {
    let (registered, path) = state.project_dir(&project_id).await?;
    let detected = project::detect(&path);

    Ok(ok(Project {
        id: registered.id,
        name: registered.name,
        path: Some(registered.path.to_string_lossy().into_owned()),
        repo: None,
        platforms: detected.platforms,
        has_fastforge_config: detected.has_fastforge_config,
        created_at: registered.created_at,
        updated_at: registered.updated_at,
    }))
}

/// Registers an existing checkout.
///
/// Studio never creates the directory: local mode is a view onto work that
/// already exists on the machine.
pub async fn create(
    State(state): State<AppState>,
    Json(request): Json<CreateProjectRequest>,
) -> Result {
    let raw = request.path.as_deref().map(str::trim).unwrap_or_default();
    if raw.is_empty() {
        return Err(
            ApiError::bad_request("INVALID_REQUEST", "`path` is required in local mode").into(),
        );
    }

    let path = paths::canonicalize(&PathBuf::from(raw))
        .map_err(|_| ApiError::not_found("PATH_NOT_FOUND", format!("{raw} does not exist")))?;
    if !path.is_dir() {
        return Err(ApiError::bad_request(
            "PATH_NOT_A_DIRECTORY",
            format!("{raw} is not a directory"),
        )
        .into());
    }

    let detected = project::detect(&path);
    let name = match request.name.as_deref() {
        Some(name) => validate_project_name(name)?,
        None => detected.name,
    };

    let registered = state
        .update_registry(|registry| {
            if let Some(existing) = registry.find_by_path(&path) {
                return Err(ApiError::conflict(
                    "PROJECT_ALREADY_REGISTERED",
                    format!("{} is already registered as `{}`", raw, existing.name),
                ));
            }
            Ok(registry.add(path.clone(), name))
        })
        .await?;

    Ok(created(Project {
        id: registered.id,
        name: registered.name,
        path: Some(registered.path.to_string_lossy().into_owned()),
        repo: None,
        platforms: detected.platforms,
        has_fastforge_config: detected.has_fastforge_config,
        created_at: registered.created_at,
        updated_at: registered.updated_at,
    }))
}

pub async fn update(
    State(state): State<AppState>,
    Path(project_id): Path<String>,
    Json(request): Json<UpdateProjectRequest>,
) -> Result {
    let Some(name) = request.name.as_deref() else {
        // Nothing to change is not an error, but it is worth saying so rather
        // than pretending an update happened.
        return Err(ApiError::bad_request("INVALID_REQUEST", "`name` is required").into());
    };
    let name = validate_project_name(name)?;

    let registered = state
        .update_registry(|registry| {
            let project = registry.get_mut(&project_id).ok_or_else(|| {
                ApiError::not_found("PROJECT_NOT_FOUND", format!("No project `{project_id}`"))
            })?;
            project.name = name;
            project.updated_at = now_rfc3339();
            Ok(project.clone())
        })
        .await?;

    let detected = project::detect(&registered.path);
    Ok(ok(Project {
        id: registered.id,
        name: registered.name,
        path: Some(registered.path.to_string_lossy().into_owned()),
        repo: None,
        platforms: detected.platforms,
        has_fastforge_config: detected.has_fastforge_config,
        created_at: registered.created_at,
        updated_at: registered.updated_at,
    }))
}

/// Unregisters a project. Nothing on disk is touched — the checkout is the
/// user's, and Studio only ever borrowed a pointer to it.
pub async fn delete(State(state): State<AppState>, Path(project_id): Path<String>) -> Result {
    state
        .update_registry(|registry| {
            if registry.remove(&project_id) {
                Ok(())
            } else {
                Err(ApiError::not_found(
                    "PROJECT_NOT_FOUND",
                    format!("No project `{project_id}`"),
                ))
            }
        })
        .await?;
    Ok(no_content())
}
