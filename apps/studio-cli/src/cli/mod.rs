pub mod doctor;
pub mod serve;

use clap::{Args, Subcommand};

use doctor::DoctorArgs;
use serve::ServeArgs;

#[derive(Args, Debug, Clone)]
#[command(args_conflicts_with_subcommands = true)]
pub struct StudioArgs {
    #[command(subcommand)]
    command: Option<Commands>,
    #[command(flatten)]
    serve: ServeArgs,
}

#[derive(Subcommand, Debug, Clone)]
enum Commands {
    #[command(about = "Serve Studio against local projects")]
    Serve(ServeArgs),
    #[command(about = "Check that store credentials resolve")]
    Doctor(DoctorArgs),
}

pub async fn execute(args: &StudioArgs) -> anyhow::Result<()> {
    match &args.command {
        Some(Commands::Serve(args)) => serve::execute(args).await,
        Some(Commands::Doctor(args)) => doctor::execute(args),
        None => serve::execute(&args.serve).await,
    }
}
