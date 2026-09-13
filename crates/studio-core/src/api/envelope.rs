use serde::Serialize;
use serde_json::{Value, json};

/// A failure, carrying the HTTP status the host should answer with.
///
/// `code` is the stable, machine-readable half — clients branch on it — while
/// `message` is for a human reading a toast or a log line.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ApiError {
    pub status: u16,
    pub code: String,
    pub message: String,
}

impl ApiError {
    pub fn new(status: u16, code: impl Into<String>, message: impl Into<String>) -> Self {
        Self {
            status,
            code: code.into(),
            message: message.into(),
        }
    }

    pub fn bad_request(code: impl Into<String>, message: impl Into<String>) -> Self {
        Self::new(400, code, message)
    }

    pub fn unauthorized(message: impl Into<String>) -> Self {
        Self::new(401, "UNAUTHORIZED", message)
    }

    pub fn forbidden(code: impl Into<String>, message: impl Into<String>) -> Self {
        Self::new(403, code, message)
    }

    pub fn not_found(code: impl Into<String>, message: impl Into<String>) -> Self {
        Self::new(404, code, message)
    }

    pub fn conflict(code: impl Into<String>, message: impl Into<String>) -> Self {
        Self::new(409, code, message)
    }

    pub fn internal(code: impl Into<String>, message: impl Into<String>) -> Self {
        Self::new(500, code, message)
    }

    /// A surface this deployment does not serve.
    ///
    /// Answered as 404 rather than 501 on purpose: in `local` mode the hosted
    /// features do not exist at all, and the navigation never links to them, so
    /// a client reaching one is asking for something that is genuinely not
    /// there.
    pub fn capability_unavailable(message: impl Into<String>) -> Self {
        Self::new(404, "CAPABILITY_UNAVAILABLE", message)
    }
}

impl std::fmt::Display for ApiError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.code, self.message)
    }
}

impl std::error::Error for ApiError {}

/// `{ "data": … }`
pub fn success_envelope<T: Serialize>(data: T) -> Value {
    json!({ "data": data })
}

/// `{ "error": { "code": …, "message": … } }`
pub fn error_envelope(error: &ApiError) -> Value {
    json!({ "error": { "code": error.code, "message": error.message } })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn success_wraps_in_a_data_key() {
        let value = success_envelope(json!({ "id": "abc" }));
        assert_eq!(value, json!({ "data": { "id": "abc" } }));
    }

    #[test]
    fn errors_expose_code_and_message_only() {
        let error = ApiError::not_found("PROJECT_NOT_FOUND", "No project with id abc");
        assert_eq!(error.status, 404);
        assert_eq!(
            error_envelope(&error),
            json!({ "error": { "code": "PROJECT_NOT_FOUND", "message": "No project with id abc" } })
        );
    }

    #[test]
    fn unavailable_capabilities_read_as_missing() {
        let error = ApiError::capability_unavailable("Workspaces are not available in local mode");
        assert_eq!(error.status, 404);
        assert_eq!(error.code, "CAPABILITY_UNAVAILABLE");
    }
}
