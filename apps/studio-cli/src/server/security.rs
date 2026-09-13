use axum::extract::Request;
use axum::http::header::{HOST, ORIGIN};
use axum::middleware::Next;
use axum::response::Response;
use studio_core::api::ApiError;

use super::error::{AppError, Result};

/// Guards the local server against being driven by a web page.
///
/// The server binds to loopback, but that alone is not enough:
///
/// - **DNS rebinding.** A hostile name resolving to 127.0.0.1 would let a page
///   reach this server with the browser believing it is same-origin. Requiring
///   a loopback `Host` header rejects that, because the browser sends the name
///   it dialled, not the address.
/// - **Cross-origin writes.** A page can issue a `POST` without being able to
///   read the reply. Rejecting a foreign `Origin` stops the write itself.
///
/// Reads are already protected by the absence of CORS headers: a foreign page
/// can send the request but cannot see the response.
pub async fn guard(request: Request, next: Next) -> Result<Response> {
    if let Some(host) = header(&request, HOST)
        && !is_loopback_authority(host)
    {
        return Err(AppError(ApiError::forbidden(
            "FORBIDDEN_HOST",
            format!("Studio only answers on localhost, not `{host}`"),
        )));
    }

    if let Some(origin) = header(&request, ORIGIN)
        && !is_loopback_origin(origin)
    {
        return Err(AppError(ApiError::forbidden(
            "FORBIDDEN_ORIGIN",
            format!("`{origin}` may not call the local Studio server"),
        )));
    }

    Ok(next.run(request).await)
}

fn header(request: &Request, name: axum::http::HeaderName) -> Option<&str> {
    request.headers().get(name)?.to_str().ok()
}

/// `127.0.0.1:7391`, `localhost:3000`, `[::1]:7391` — with or without a port.
fn is_loopback_authority(authority: &str) -> bool {
    let host = if let Some(rest) = authority.strip_prefix('[') {
        // A bracketed IPv6 literal: the port, if any, follows the bracket.
        let Some((host, after)) = rest.split_once(']') else {
            return false;
        };
        if !(after.is_empty() || after.starts_with(':')) {
            return false;
        }
        host
    } else if authority.matches(':').count() > 1 {
        // More than one colon and no brackets means a bare IPv6 literal, which
        // cannot carry a port.
        authority
    } else {
        authority
            .split_once(':')
            .map_or(authority, |(host, _port)| host)
    };

    matches!(host, "127.0.0.1" | "localhost" | "::1")
}

fn is_loopback_origin(origin: &str) -> bool {
    // `null` is what a sandboxed iframe or a `file://` page sends. Neither is
    // Studio.
    let Some(authority) = origin
        .strip_prefix("http://")
        .or_else(|| origin.strip_prefix("https://"))
    else {
        return false;
    };
    let authority = authority.split('/').next().unwrap_or_default();
    is_loopback_authority(authority)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn loopback_authorities_are_accepted_with_and_without_ports() {
        for authority in [
            "127.0.0.1",
            "127.0.0.1:7391",
            "localhost",
            "localhost:3000",
            "[::1]:7391",
            "::1",
        ] {
            assert!(
                is_loopback_authority(authority),
                "{authority} should be accepted"
            );
        }
    }

    #[test]
    fn rebinding_hosts_are_rejected() {
        for authority in [
            "attacker.example.com",
            "attacker.example.com:7391",
            "127.0.0.1.attacker.example.com",
            "localhost.attacker.example.com",
            "192.168.1.10:7391",
        ] {
            assert!(
                !is_loopback_authority(authority),
                "{authority} should be rejected"
            );
        }
    }

    #[test]
    fn the_dev_server_and_the_studio_server_are_both_valid_origins() {
        assert!(is_loopback_origin("http://localhost:3000"));
        assert!(is_loopback_origin("http://127.0.0.1:7391"));
    }

    #[test]
    fn foreign_and_opaque_origins_are_rejected() {
        for origin in [
            "https://evil.example.com",
            "http://evil.example.com:7391",
            "null",
            "file://",
            "",
        ] {
            assert!(!is_loopback_origin(origin), "{origin} should be rejected");
        }
    }
}
