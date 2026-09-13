use std::path::Path as FsPath;

use axum::Json;
use axum::extract::{Path, State};
use axum::response::Response;
use studio_core::api::{ApiError, CreateStoreAppRequest, UpdateStoreAppRequest};
use studio_core::config::{store_apps, store_connections};
use studio_core::model::{StoreApp, StoreKind, parse_store_app_id};

use crate::local::{catalog, config, env::ProcessEnv};
use crate::server::error::{Result, not_implemented, ok};
use crate::server::state::AppState;

/// Both stores, configured or not.
pub async fn list(State(state): State<AppState>, Path(project_id): Path<String>) -> Result {
    let (_, path) = state.project_dir(&project_id).await?;
    let config = config::load(&path)?;
    Ok(ok(store_connections(&config, &ProcessEnv)))
}

pub async fn list_apps(
    State(state): State<AppState>,
    Path((project_id, store)): Path<(String, String)>,
) -> Result {
    let store = parse_store(&store)?;
    let (_, path) = state.project_dir(&project_id).await?;
    let config = config::load(&path)?;

    let apps: Vec<StoreApp> = store_apps(&config)
        .into_iter()
        .filter(|app| app.store == store)
        .map(|app| with_catalog_state(&path, app))
        .collect();
    Ok(ok(apps))
}

/// Every app across both stores, in configuration order.
///
/// The project shell reads this once to build its sidebar; asking per store
/// would mean one request per store for a list that is always shown whole.
pub async fn list_all_apps(
    State(state): State<AppState>,
    Path(project_id): Path<String>,
) -> Result {
    let (_, path) = state.project_dir(&project_id).await?;
    let config = config::load(&path)?;

    let apps: Vec<StoreApp> = store_apps(&config)
        .into_iter()
        .map(|app| with_catalog_state(&path, app))
        .collect();
    Ok(ok(apps))
}

pub async fn get_app(
    State(state): State<AppState>,
    Path((project_id, store_app_id)): Path<(String, String)>,
) -> Result {
    let (_, path) = state.project_dir(&project_id).await?;
    Ok(ok(load_app(&path, &store_app_id)?))
}

/// Finds one app in the project's config, or explains which half of the id was
/// wrong.
pub fn load_app(project: &FsPath, store_app_id: &str) -> std::result::Result<StoreApp, ApiError> {
    // Rejecting an unparseable id up front means a typo in the store segment
    // reads as "no such store", not "no such app".
    let (_, _) = parse_store_app_id(store_app_id).ok_or_else(|| {
        ApiError::not_found(
            "STORE_APP_NOT_FOUND",
            format!("`{store_app_id}` is not a store app id"),
        )
    })?;

    let config = config::load(project)?;
    store_apps(&config)
        .into_iter()
        .find(|app| app.id == store_app_id)
        .map(|app| with_catalog_state(project, app))
        .ok_or_else(|| {
            ApiError::not_found(
                "STORE_APP_NOT_FOUND",
                format!("`{store_app_id}` is not registered in .fastforge/config.yaml"),
            )
        })
}

/// The config knows an app exists; the filesystem knows whether its catalog has
/// been pulled. Only the two together make a useful answer.
fn with_catalog_state(project: &FsPath, mut app: StoreApp) -> StoreApp {
    app.catalog = catalog::state(project, app.store, &app.identifier);
    app
}

pub fn parse_store(value: &str) -> std::result::Result<StoreKind, ApiError> {
    StoreKind::parse(value).ok_or_else(|| {
        ApiError::not_found("STORE_NOT_FOUND", format!("`{value}` is not a known store"))
    })
}

// Writing to `.fastforge/config.yaml` is deliberately not implemented yet.
//
// The file is hand-maintained: it carries comments, ordering and anchors that
// matter to whoever wrote it. Round-tripping it through a plain YAML
// serializer would silently strip all of that, which is a worse outcome than
// not offering the button. These land once the order-preserving editor does.

const CONFIG_WRITE_MESSAGE: &str = concat!(
    "Editing .fastforge/config.yaml from Studio is not available yet — it would ",
    "strip the comments and ordering in your file. Edit it directly for now."
);

pub async fn create_app(
    State(_): State<AppState>,
    Path((_project_id, _store)): Path<(String, String)>,
    Json(_): Json<CreateStoreAppRequest>,
) -> Result<Response> {
    Err(not_implemented("CONFIG_WRITE_UNSUPPORTED", CONFIG_WRITE_MESSAGE).into())
}

pub async fn update_app(
    State(_): State<AppState>,
    Path((_project_id, _store_app_id)): Path<(String, String)>,
    Json(_): Json<UpdateStoreAppRequest>,
) -> Result<Response> {
    Err(not_implemented("CONFIG_WRITE_UNSUPPORTED", CONFIG_WRITE_MESSAGE).into())
}

pub async fn delete_app(
    State(_): State<AppState>,
    Path((_project_id, _store_app_id)): Path<(String, String)>,
) -> Result<Response> {
    Err(not_implemented("CONFIG_WRITE_UNSUPPORTED", CONFIG_WRITE_MESSAGE).into())
}
