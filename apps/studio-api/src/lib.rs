//! Fastforge Studio, hosted on Cloudflare Workers.
//!
//! The same contract `fastforge-studio serve` implements, backed by D1 instead
//! of a checkout. All the meaning lives in `studio_core`; this crate
//! is routing, storage and the Worker runtime.

mod error;
mod handlers;
mod router;
mod store;

use worker::{Context, Env, Request, Response, Result, event};

#[event(fetch)]
async fn fetch(request: Request, env: Env, _context: Context) -> Result<Response> {
    console_error_panic_hook::set_once();
    router::handle(request, env).await
}
