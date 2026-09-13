use serde::Serialize;
use studio_core::api::{ApiError, error_envelope, success_envelope};
use worker::{Response, Result};

/// Every handler returns this: either a value to envelope, or the error the
/// core decided on — including its status.
pub type Handled<T> = std::result::Result<T, ApiError>;

pub fn ok<T: Serialize>(data: T) -> Result<Response> {
    Response::from_json(&success_envelope(data))
}

pub fn created<T: Serialize>(data: T) -> Result<Response> {
    Ok(ok(data)?.with_status(201))
}

pub fn no_content() -> Result<Response> {
    Ok(Response::empty()?.with_status(204))
}

pub fn failed(error: &ApiError) -> Result<Response> {
    Ok(Response::from_json(&error_envelope(error))?.with_status(error.status))
}

/// Turns a handler's result into a response, so routing never has to think
/// about status codes.
pub fn respond<T: Serialize>(result: Handled<T>) -> Result<Response> {
    match result {
        Ok(value) => ok(value),
        Err(error) => failed(&error),
    }
}

/// Worker-level failures — a D1 query that would not run, a binding that is not
/// bound. Nothing the client can act on, so they collapse to one code with the
/// cause carried in the message for the log.
pub fn internal(context: &str, error: impl std::fmt::Display) -> ApiError {
    ApiError::internal("INTERNAL_ERROR", format!("{context}: {error}"))
}
