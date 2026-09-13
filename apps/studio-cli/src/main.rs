use clap::Parser;
use studio_cli::StudioArgs;

#[derive(Parser)]
#[command(name = "fastforge-studio")]
#[command(about = "Fastforge Studio on your machine")]
#[command(version = env!("CARGO_PKG_VERSION"))]
struct Cli {
    #[command(flatten)]
    studio: StudioArgs,
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

    studio_cli::execute(&Cli::parse().studio).await
}
