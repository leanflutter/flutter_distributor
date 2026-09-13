use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

fn command_output(program: &str, args: &[&str]) -> Option<String> {
    let output = Command::new(program).args(args).output().ok()?;
    output
        .status
        .success()
        .then(|| String::from_utf8_lossy(&output.stdout).trim().to_string())
}

fn main() {
    println!("cargo:rerun-if-env-changed=GITHUB_ACTIONS");
    println!("cargo:rerun-if-env-changed=SOURCE_DATE_EPOCH");
    println!("cargo:rerun-if-changed=../../.git/HEAD");
    println!("cargo:rerun-if-changed=../../.git/index");

    let version = std::env::var("CARGO_PKG_VERSION").unwrap_or_else(|_| "unknown".into());
    let commit = command_output("git", &["rev-parse", "--short=8", "HEAD"])
        .filter(|value| !value.is_empty())
        .unwrap_or_else(|| "unknown".into());
    let dirty = command_output(
        "git",
        &["status", "--porcelain", "--untracked-files=normal"],
    )
    .map(|output| !output.is_empty())
    .unwrap_or(true);
    let build_time = std::env::var("SOURCE_DATE_EPOCH").unwrap_or_else(|_| {
        SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs()
            .to_string()
    });
    let channel = if std::env::var_os("GITHUB_ACTIONS").is_some() {
        "release"
    } else {
        "unofficial"
    };
    let build_version =
        format!("{version} ({commit}, dirty={dirty}, {channel}, built-unix={build_time})");
    println!("cargo:rustc-env=FASTFORGE_BUILD_VERSION={build_version}");
}
