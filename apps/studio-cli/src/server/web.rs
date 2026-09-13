use std::path::PathBuf;

use axum::Router;
use axum::response::Html;
use tower_http::services::{ServeDir, ServeFile};

use super::state::AppState;

/// Serves the built web client, or explains its absence.
///
/// The client is a single-page app, so anything that is not a file falls back
/// to `index.html` and lets the router in the browser decide.
pub fn attach(router: Router<AppState>, web_root: Option<PathBuf>) -> Router<AppState> {
    match web_root.filter(|root| root.join("index.html").is_file()) {
        Some(root) => {
            let index = ServeFile::new(root.join("index.html"));
            router.fallback_service(ServeDir::new(root).fallback(index))
        }
        None => router.fallback(placeholder),
    }
}

/// Shown when the API is up but the client has not been built.
///
/// This is the normal state during development, where the client is served by
/// `vite dev` on another port — so the page points at both ways forward rather
/// than reading as an error.
async fn placeholder() -> Html<&'static str> {
    Html(
        r#"<!doctype html>
<meta charset="utf-8" />
<title>Fastforge Studio</title>
<style>
  body { font: 15px/1.6 ui-sans-serif, system-ui, sans-serif; margin: 6rem auto; max-width: 34rem; padding: 0 1.5rem; }
  code { background: #f4f4f5; border-radius: 4px; padding: 0.15em 0.4em; }
  a { color: inherit; }
</style>
<h1>Studio is running</h1>
<p>The API is up, but the web client has not been built.</p>
<ul>
  <li>Developing? Run <code>pnpm studio:dev</code> and open <a href="http://localhost:3000">localhost:3000</a>.</li>
  <li>Otherwise run <code>pnpm studio:build</code> and restart <code>fastforge-studio serve</code>.</li>
</ul>
<p>The contract is browsable at <a href="/reference">/reference</a>.</p>
"#,
    )
}
