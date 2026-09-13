use std::path::PathBuf;

use anyhow::Result;
use clap::Args;
use studio_core::config::store_connections;
use studio_core::model::{AuthStatus, StoreKind};

use crate::local::{config, env::ProcessEnv, paths, project};

#[derive(Args, Debug, Clone, Default)]
pub struct DoctorArgs {
    /// Project directory. Defaults to the current directory.
    #[arg(short, long)]
    pub dir: Option<PathBuf>,
}

/// Reports whether each configured store's credentials resolve.
///
/// The same check the stores page runs, on the command line — useful because
/// the server inherits the environment of the shell that started it, so
/// "works in my terminal" and "works in Studio" can genuinely differ.
pub fn execute(args: &DoctorArgs) -> Result<()> {
    let dir = match args.dir.clone() {
        Some(dir) => paths::canonicalize(&dir)?,
        None => std::env::current_dir()?,
    };

    let detected = project::detect(&dir);
    println!("{} ({})", detected.name, dir.display());

    if !detected.has_fastforge_config {
        println!(
            "\n  no {} — nothing to check",
            config::config_path(&dir).display()
        );
        return Ok(());
    }

    let config = config::load(&dir).map_err(|error| anyhow::anyhow!("{error}"))?;
    let mut incomplete = 0;

    for connection in store_connections(&config, &ProcessEnv) {
        println!();
        match &connection.auth_status {
            AuthStatus::NotConfigured => {
                println!("  - {} — not configured", connection.name);
            }
            AuthStatus::Ready { sources } => {
                println!(
                    "  ✓ {} ({}) — {} app(s)",
                    connection.name,
                    connection.auth_type.as_str(),
                    connection.app_count
                );
                for source in sources {
                    println!("      {} ← {}", source.field, source.source);
                }
            }
            AuthStatus::Incomplete { missing } => {
                incomplete += 1;
                println!(
                    "  ✗ {} ({}) — {} app(s), credentials incomplete",
                    connection.name,
                    connection.auth_type.as_str(),
                    connection.app_count
                );
                for field in missing {
                    let hint = if field.candidates.is_empty() {
                        String::new()
                    } else {
                        format!(" (set {})", field.candidates.join(" or "))
                    };
                    println!("      {} is unset{hint}", field.field);
                }
            }
        }

        print_apps(&config, connection.store);
    }

    if incomplete > 0 {
        anyhow::bail!("{incomplete} store(s) cannot authenticate");
    }
    Ok(())
}

fn print_apps(config: &studio_core::config::FastforgeConfig, store: StoreKind) {
    let apps: Vec<_> = studio_core::config::store_apps(config)
        .into_iter()
        .filter(|app| app.store == store)
        .collect();
    for app in apps {
        let label = app.name.as_deref().unwrap_or(&app.identifier);
        println!("      · {label} [{}]", app.identifier);
    }
}
