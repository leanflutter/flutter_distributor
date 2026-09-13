use axum::extract::Path;
use axum::response::Response;
use studio_core::api::ApiError;

use crate::server::error::Result;

// Runs exist in the contract because catalog sync will produce them. Until
// something can start one, every run id is genuinely unknown — so these answer
// 404 rather than pretending to be unimplemented. That is the same answer the
// hosted service gives for an id it has never issued.

pub async fn get(Path(run_id): Path<String>) -> Result<Response> {
    Err(unknown(&run_id))
}

pub async fn events(Path(run_id): Path<String>) -> Result<Response> {
    Err(unknown(&run_id))
}

pub async fn cancel(Path(run_id): Path<String>) -> Result<Response> {
    Err(unknown(&run_id))
}

fn unknown(run_id: &str) -> crate::server::error::AppError {
    ApiError::not_found("RUN_NOT_FOUND", format!("No run `{run_id}`")).into()
}
