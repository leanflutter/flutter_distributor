use axum::Json;
use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde::Serialize;
use studio_core::api::{ApiError, error_envelope, success_envelope};

/// Wraps [`ApiError`] so it can be returned straight out of a handler.
///
/// The status lives on the error itself, decided by `studio_core`, so
/// both hosts answer the same situation with the same code.
#[derive(Debug)]
pub struct AppError(pub ApiError);

impl From<ApiError> for AppError {
    fn from(error: ApiError) -> Self {
        Self(error)
    }
}

impl From<anyhow::Error> for AppError {
    fn from(error: anyhow::Error) -> Self {
        // Anything that reaches here is a bug or a broken machine, not
        // something the client can act on — hence a bare 500 with the cause
        // logged rather than a specific code.
        tracing::error!(error = %error, "unhandled failure");
        Self(ApiError::internal("INTERNAL_ERROR", error.to_string()))
    }
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let status =
            StatusCode::from_u16(self.0.status).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR);
        (status, Json(error_envelope(&self.0))).into_response()
    }
}

pub type Result<T = Response> = std::result::Result<T, AppError>;

/// `200 { "data": … }`
pub fn ok<T: Serialize>(data: T) -> Response {
    Json(success_envelope(data)).into_response()
}

/// `201 { "data": … }`
pub fn created<T: Serialize>(data: T) -> Response {
    (StatusCode::CREATED, Json(success_envelope(data))).into_response()
}

pub fn no_content() -> Response {
    StatusCode::NO_CONTENT.into_response()
}

/// A surface the contract describes but this build does not implement yet.
///
/// Distinct from `CAPABILITY_UNAVAILABLE`, which means "this deployment will
/// never serve it": 501 says the endpoint is coming and the client should not
/// hide the feature, only report it.
pub fn not_implemented(code: &str, message: impl Into<String>) -> ApiError {
    ApiError::new(501, code, message)
}
