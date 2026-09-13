use axum::Json;
use axum::extract::{Path, Query, State};
use axum::http::header::{CACHE_CONTROL, CONTENT_TYPE};
use axum::response::{IntoResponse, Response};
use serde::Deserialize;
use studio_core::api::PutCatalogFileRequest;
use studio_core::model::parse_store_app_id;

use crate::local::catalog;
use crate::server::error::{Result, not_implemented, ok};
use crate::server::routes::stores::load_app;
use crate::server::state::AppState;

#[derive(Debug, Deserialize)]
pub struct PathQuery {
    path: String,
}

pub async fn tree(
    State(state): State<AppState>,
    Path((project_id, store_app_id)): Path<(String, String)>,
) -> Result {
    let (_, project) = state.project_dir(&project_id).await?;
    let app = load_app(&project, &store_app_id)?;
    Ok(ok(catalog::tree(&project, app.store, &app.identifier)))
}

pub async fn read_file(
    State(state): State<AppState>,
    Path((project_id, store_app_id)): Path<(String, String)>,
    Query(query): Query<PathQuery>,
) -> Result {
    let (_, project) = state.project_dir(&project_id).await?;
    let app = load_app(&project, &store_app_id)?;
    Ok(ok(catalog::read_file(
        &project,
        app.store,
        &app.identifier,
        &query.path,
    )?))
}

pub async fn write_file(
    State(state): State<AppState>,
    Path((project_id, store_app_id)): Path<(String, String)>,
    Query(query): Query<PathQuery>,
    Json(request): Json<PutCatalogFileRequest>,
) -> Result {
    let (_, project) = state.project_dir(&project_id).await?;
    let app = load_app(&project, &store_app_id)?;
    Ok(ok(catalog::write_file(
        &project,
        app.store,
        &app.identifier,
        &query.path,
        &request.content,
        request.etag.as_deref(),
    )?))
}

pub async fn raw(
    State(state): State<AppState>,
    Path((project_id, store_app_id)): Path<(String, String)>,
    Query(query): Query<PathQuery>,
) -> Result {
    let (_, project) = state.project_dir(&project_id).await?;
    let app = load_app(&project, &store_app_id)?;
    let (bytes, content_type) =
        catalog::read_bytes(&project, app.store, &app.identifier, &query.path)?;

    Ok((
        [
            (CONTENT_TYPE, content_type),
            // Screenshots change only when `pull` runs, and the editor
            // re-fetches the tree after that — so revalidating every time would
            // be wasted round trips for a page full of images.
            (CACHE_CONTROL, "private, max-age=60"),
        ],
        bytes,
    )
        .into_response())
}

// Synchronising with the store needs fastforge's App Store Connect and Google
// Play clients, which are a git dependency this crate does not carry yet. The
// endpoint exists so the contract is honest about the shape of the answer.
const SYNC_MESSAGE: &str = concat!(
    "Catalog sync is not wired up yet. Use `fastforge store catalog pull` / ",
    "`push` from the project directory for now."
);

pub async fn pull(
    State(_): State<AppState>,
    Path((_project_id, store_app_id)): Path<(String, String)>,
) -> Result<Response> {
    reject_sync(&store_app_id)
}

pub async fn push(
    State(_): State<AppState>,
    Path((_project_id, store_app_id)): Path<(String, String)>,
) -> Result<Response> {
    reject_sync(&store_app_id)
}

/// Still validates the id, so a client sees "no such app" before it sees "not
/// implemented" — the two are worth telling apart while wiring the UI.
fn reject_sync(store_app_id: &str) -> Result<Response> {
    if parse_store_app_id(store_app_id).is_none() {
        return Err(studio_core::api::ApiError::not_found(
            "STORE_APP_NOT_FOUND",
            format!("`{store_app_id}` is not a store app id"),
        )
        .into());
    }
    Err(not_implemented("CATALOG_SYNC_UNSUPPORTED", SYNC_MESSAGE).into())
}
