use studio_core::api::{
    ApiError, Capabilities, CreateProjectRequest, StudioMode, UpdateProjectRequest,
    capabilities_for, validate_project_name,
};
use studio_core::config::{MapEnv, store_apps, store_connections};
use studio_core::model::{
    Project, ProjectSummary, StoreApp, StoreConnection, StoreKind, parse_store_app_id,
};
use worker::{D1Database, Env};

use crate::error::{Handled, internal};
use crate::store::{self, ProjectRow};

/// What the hosted service can do.
///
/// Catalog sync is off: the App Store Connect and Google Play clients live in
/// fastforge and are bound to `reqwest`, so they do not compile for a Worker
/// yet. The protocols themselves are plain HTTP and WebCrypto covers both
/// signatures, so this flips on once those clients take a transport.
pub fn capabilities() -> Capabilities {
    Capabilities {
        catalog_sync: false,
        ..capabilities_for(StudioMode::Cloud)
    }
}

pub async fn list_projects(db: &D1Database, owner: &str) -> Handled<Vec<ProjectSummary>> {
    Ok(store::list_projects(db, owner)
        .await?
        .into_iter()
        .map(ProjectRow::into_summary)
        .collect())
}

pub async fn get_project(db: &D1Database, owner: &str, id: &str) -> Handled<Project> {
    Ok(store::get_project(db, owner, id).await?.into_project())
}

pub async fn create_project(
    db: &D1Database,
    owner: &str,
    request: CreateProjectRequest,
    now: &str,
) -> Handled<Project> {
    // `path` is a local-mode field: there is no filesystem here to point at.
    if request.path.is_some() {
        return Err(ApiError::bad_request(
            "INVALID_REQUEST",
            "`path` is only meaningful in local mode; send `name` instead",
        ));
    }

    let name = validate_project_name(request.name.as_deref().unwrap_or_default())?;
    let slug = slugify(&name);
    let id = store::project_id(owner, &slug);

    let statement = db
        .prepare(
            "INSERT INTO projects (id, owner_id, slug, name, repo, created_at, updated_at)
             VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?6)
             ON CONFLICT(id) DO NOTHING",
        )
        .bind(&[
            id.as_str().into(),
            owner.into(),
            slug.as_str().into(),
            name.as_str().into(),
            request.repo.clone().unwrap_or_default().into(),
            now.into(),
        ])
        .map_err(|error| internal("failed to bind the project insert", error))?;

    let result = statement
        .run()
        .await
        .map_err(|error| internal("failed to create the project", error))?;

    // `DO NOTHING` means the id was taken — two projects with the same name
    // under one owner, which is a conflict rather than a silent no-op.
    if result
        .meta()
        .ok()
        .flatten()
        .and_then(|meta| meta.changes)
        .unwrap_or(0)
        == 0
    {
        return Err(ApiError::conflict(
            "PROJECT_ALREADY_EXISTS",
            format!("A project named `{name}` already exists"),
        ));
    }

    get_project(db, owner, &id).await
}

pub async fn update_project(
    db: &D1Database,
    owner: &str,
    id: &str,
    request: UpdateProjectRequest,
    now: &str,
) -> Handled<Project> {
    let Some(name) = request.name.as_deref() else {
        return Err(ApiError::bad_request(
            "INVALID_REQUEST",
            "`name` is required",
        ));
    };
    let name = validate_project_name(name)?;

    // Confirms it exists — and that it belongs to this owner — before writing.
    store::get_project(db, owner, id).await?;

    db.prepare("UPDATE projects SET name = ?1, updated_at = ?2 WHERE owner_id = ?3 AND id = ?4")
        .bind(&[name.as_str().into(), now.into(), owner.into(), id.into()])
        .map_err(|error| internal("failed to bind the project update", error))?
        .run()
        .await
        .map_err(|error| internal("failed to update the project", error))?;

    get_project(db, owner, id).await
}

pub async fn delete_project(db: &D1Database, owner: &str, id: &str) -> Handled<()> {
    store::get_project(db, owner, id).await?;

    db.prepare("DELETE FROM projects WHERE owner_id = ?1 AND id = ?2")
        .bind(&[owner.into(), id.into()])
        .map_err(|error| internal("failed to bind the project delete", error))?
        .run()
        .await
        .map_err(|error| internal("failed to delete the project", error))?;
    Ok(())
}

pub async fn list_stores(
    db: &D1Database,
    env: &Env,
    owner: &str,
    project_id: &str,
) -> Handled<Vec<StoreConnection>> {
    let project = store::get_project(db, owner, project_id).await?;
    Ok(store_connections(&project.config()?, &worker_env(env)))
}

pub async fn list_store_apps(
    db: &D1Database,
    owner: &str,
    project_id: &str,
    store_filter: Option<StoreKind>,
) -> Handled<Vec<StoreApp>> {
    let project = store::get_project(db, owner, project_id).await?;
    // The catalog state stays at its never-pulled default: catalogs live in R2
    // and nothing writes them yet, so claiming otherwise would be a lie the UI
    // would render as "N files".
    Ok(store_apps(&project.config()?)
        .into_iter()
        .filter(|app| store_filter.is_none_or(|store| app.store == store))
        .collect())
}

pub async fn get_store_app(
    db: &D1Database,
    owner: &str,
    project_id: &str,
    store_app_id: &str,
) -> Handled<StoreApp> {
    if parse_store_app_id(store_app_id).is_none() {
        return Err(ApiError::not_found(
            "STORE_APP_NOT_FOUND",
            format!("`{store_app_id}` is not a store app id"),
        ));
    }

    list_store_apps(db, owner, project_id, None)
        .await?
        .into_iter()
        .find(|app| app.id == store_app_id)
        .ok_or_else(|| {
            ApiError::not_found(
                "STORE_APP_NOT_FOUND",
                format!("`{store_app_id}` is not registered in this project"),
            )
        })
}

/// Store credentials, read from the Worker's own variables.
///
/// Same shape as the local host's process environment, so
/// `studio_core::config` reports credential state identically in both
/// — and, as there, only whether each field resolves, never its value.
fn worker_env(env: &Env) -> MapEnv {
    const KEYS: [&str; 8] = [
        "APP_STORE_CONNECT_KEY_ID",
        "APPSTORE_APIKEY",
        "APP_STORE_CONNECT_ISSUER_ID",
        "APPSTORE_APIISSUER",
        "APP_STORE_CONNECT_KEY_PATH",
        "GOOGLE_PLAY_SERVICE_ACCOUNT_KEY",
        "GOOGLE_APPLICATION_CREDENTIALS",
        "GOOGLE_PLAY_SERVICE_ACCOUNT_JSON",
    ];

    MapEnv::new(KEYS.into_iter().filter_map(|key| {
        env.secret(key)
            .or_else(|_| env.var(key))
            .ok()
            .map(|value| (key, value.to_string()))
    }))
}

/// A URL-safe, stable name for a project, used to derive its id.
fn slugify(name: &str) -> String {
    let mut slug = String::with_capacity(name.len());
    let mut pending_dash = false;

    for character in name.chars() {
        if character.is_ascii_alphanumeric() {
            if pending_dash && !slug.is_empty() {
                slug.push('-');
            }
            pending_dash = false;
            slug.push(character.to_ascii_lowercase());
        } else {
            pending_dash = true;
        }
    }
    slug
}
