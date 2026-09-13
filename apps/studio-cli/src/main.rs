use clap::{Parser, Subcommand};

mod cli;
mod local;
mod server;

use cli::{DoctorArgs, ServeArgs};

#[derive(Parser)]
#[command(name = "fastforge-studio")]
#[command(about = "Fastforge Studio on your machine")]
#[command(version = env!("CARGO_PKG_VERSION"))]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    #[command(about = "Serve Studio against local projects")]
    Serve(ServeArgs),
    #[command(about = "Check that store credentials resolve")]
    Doctor(DoctorArgs),
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "studio_cli=info,tower_http=warn".into()),
        )
        .with_target(false)
        .init();

    // `fastforge-studio` with no arguments is `fastforge-studio serve`: opening
    // Studio is the thing people came for.
    match Cli::parse().command {
        Some(Commands::Serve(args)) => cli::serve::execute(&args).await,
        Some(Commands::Doctor(args)) => cli::doctor::execute(&args),
        None => cli::serve::execute(&ServeArgs::default()).await,
    }
}
