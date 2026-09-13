use axum::extract::State;
use axum::response::{Html, IntoResponse, Response};
use studio_core::openapi;

use crate::server::error::{Result, ok};
use crate::server::state::AppState;

/// What this build can do. The client reads it once and hides every surface it
/// reports as unavailable.
pub async fn capabilities(State(state): State<AppState>) -> Response {
    ok(state.capabilities())
}

pub async fn openapi_document() -> Result {
    Ok(ok(openapi::openapi_document()?).into_response())
}

pub async fn reference() -> Html<String> {
    Html(openapi::reference_html("/openapi.json"))
}
