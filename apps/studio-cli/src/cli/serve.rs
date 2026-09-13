use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use std::path::PathBuf;

use anyhow::{Context, Result};
use clap::Args;

use crate::local::paths;
use crate::server::{self, AppState};

/// The default port. Arbitrary, but fixed: bookmarks and the dev server's proxy
/// both depend on it not moving.
const DEFAULT_PORT: u16 = 7391;

#[derive(Args, Debug, Clone)]
pub struct ServeArgs {
    /// Port to listen on.
    #[arg(short, long, default_value_t = DEFAULT_PORT)]
    pub port: u16,

    /// Do not open a browser.
    #[arg(long)]
    pub no_open: bool,

    /// Directory holding the built web client. Defaults to the one bundled with
    /// this checkout.
    #[arg(long)]
    pub web_root: Option<PathBuf>,
}

impl Default for ServeArgs {
    fn default() -> Self {
        Self {
            port: DEFAULT_PORT,
            no_open: false,
            web_root: None,
        }
    }
}

pub async fn execute(args: &ServeArgs) -> Result<()> {
    let state = AppState::new(paths::registry_path()?, paths::home_dir()?)?;

    // Loopback only. Studio reads the filesystem and inherits the shell's
    // credentials-bearing environment; it has no business being reachable from
    // the network.
    let address = SocketAddr::new(IpAddr::V4(Ipv4Addr::LOCALHOST), args.port);
    let listener = tokio::net::TcpListener::bind(address)
        .await
        .with_context(|| {
            format!("failed to bind {address} — is another Studio already running?")
        })?;

    let url = format!("http://127.0.0.1:{}", args.port);
    tracing::info!("Studio is serving at {url}");

    if !args.no_open
        && let Err(error) = open::that_detached(&url)
    {
        tracing::warn!("could not open a browser: {error}");
    }

    axum::serve(listener, server::router(state, web_root(args)))
        .with_graceful_shutdown(shutdown())
        .await
        .context("the server stopped unexpectedly")
}

/// Where the built client lives.
///
/// In a source checkout that is `apps/studio-web/dist/client` — TanStack Start's
/// client bundle, which is a plain SPA because Studio runs it without a Node
/// server. The path is resolved from this crate's manifest so running the
/// binary from anywhere still finds it; a shipped binary is told explicitly
/// with `--web-root`.
fn web_root(args: &ServeArgs) -> Option<PathBuf> {
    args.web_root.clone().or_else(|| {
        let bundled = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .parent()?
            .join("studio-web")
            .join("dist")
            .join("client");
        bundled.is_dir().then_some(bundled)
    })
}

async fn shutdown() {
    let _ = tokio::signal::ctrl_c().await;
    tracing::info!("shutting down");
}
