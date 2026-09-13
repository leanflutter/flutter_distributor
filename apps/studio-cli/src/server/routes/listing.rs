use axum::extract::{Path, Query, State};
use serde::Deserialize;

use crate::local::listing;
use crate::server::error::{Result, ok};
use crate::server::routes::stores::load_app;
use crate::server::state::AppState;

#[derive(Debug, Deserialize)]
pub struct ListingQuery {
    /// Defaults to `en-US` when the catalog has it, otherwise the first locale.
    locale: Option<String>,
    /// An App Store version (`IOS/1.2.0`) or a Google Play track. Defaults to
    /// the newest version, or the production track.
    version: Option<String>,
}

/// The listing a store would show, assembled from the pulled catalog.
pub async fn get(
    State(state): State<AppState>,
    Path((project_id, store_app_id)): Path<(String, String)>,
    Query(query): Query<ListingQuery>,
) -> Result {
    let (_, project) = state.project_dir(&project_id).await?;
    let app = load_app(&project, &store_app_id)?;

    Ok(ok(listing::listing(
        &project,
        app.store,
        &app.identifier,
        query.locale.as_deref(),
        query.version.as_deref(),
    )))
}
