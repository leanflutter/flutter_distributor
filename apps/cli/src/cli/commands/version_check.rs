//! Update checks against the GitHub releases of `fastforgedev/fastforge`.
//!
//! Mirrors the Dart CLI (`UnifiedDistributorCommandLineInterface.run`): unless
//! `--no-version-check` is passed, every invocation checks for a newer release
//! before running the command and prints either an upgrade hint or a
//! "latest version" note. The Dart CLI queried pub.dev; the Rust binary is
//! distributed through GitHub releases (see `install.sh` / `install.ps1`), so
//! that is where the latest version comes from.
//!
//! Unlike the Dart CLI, a failed check (offline, rate limited, ...) never
//! aborts the command, and all output goes to stderr so machine-readable
//! stdout (e.g. `fastforge analyze` JSON) stays clean.

use std::io::{IsTerminal, Write};
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use std::thread::JoinHandle;
use std::time::Duration;

use anyhow::{Context, Result, anyhow};
use clap::Args;
use serde::Deserialize;

pub const REPO: &str = "fastforgedev/fastforge";
pub const CURRENT_VERSION: &str = env!("CARGO_PKG_VERSION");
const DISPLAY_NAME: &str = "Fastforge";
const STARTUP_CHECK_TIMEOUT: Duration = Duration::from_secs(5);

/// Check whether a newer version of fastforge is available.
#[derive(Args)]
pub struct VersionCheckArgs {
    /// Print the current version and exit without checking for updates.
    #[arg(long = "current-only", default_value_t = false)]
    pub current_only: bool,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ReleaseAsset {
    pub name: String,
    pub browser_download_url: String,
    #[serde(default)]
    pub size: u64,
}

#[derive(Debug, Clone, Deserialize)]
pub struct Release {
    pub tag_name: String,
    #[serde(default)]
    pub draft: bool,
    #[serde(default)]
    pub prerelease: bool,
    #[serde(default)]
    pub assets: Vec<ReleaseAsset>,
}

impl Release {
    pub fn version(&self) -> &str {
        self.tag_name.trim_start_matches('v')
    }

    /// The prebuilt archive for the running platform, named like the ones
    /// produced by `.github/workflows/release.yml`.
    pub fn platform_asset(&self) -> Option<&ReleaseAsset> {
        let target = release_target().ok()?;
        let name = archive_name(self.version(), target);
        self.assets.iter().find(|asset| asset.name == name)
    }
}

/// The Rust target triple of the prebuilt archive matching this binary.
pub fn release_target() -> Result<&'static str> {
    let target = match (std::env::consts::OS, std::env::consts::ARCH) {
        ("macos", "aarch64") => "aarch64-apple-darwin",
        ("macos", "x86_64") => "x86_64-apple-darwin",
        ("linux", "aarch64") => "aarch64-unknown-linux-gnu",
        ("linux", "x86_64") => "x86_64-unknown-linux-gnu",
        ("windows", "aarch64") => "aarch64-pc-windows-msvc",
        ("windows", "x86_64") => "x86_64-pc-windows-msvc",
        (os, arch) => {
            return Err(anyhow!(
                "No prebuilt fastforge binary is available for {os}-{arch}."
            ));
        }
    };
    Ok(target)
}

pub fn archive_name(version: &str, target: &str) -> String {
    let ext = if cfg!(windows) { "zip" } else { "tar.gz" };
    format!("fastforge-{version}-{target}.{ext}")
}

/// Result of comparing the running binary against the latest release
/// (the Dart `CheckVersionResult`).
pub struct CheckVersionResult {
    pub current_version: String,
    pub latest_version: Option<String>,
}

impl CheckVersionResult {
    pub fn is_new_version_available(&self) -> bool {
        self.latest_version
            .as_deref()
            .is_some_and(|latest| is_newer(latest, &self.current_version))
    }
}

pub fn http_client(timeout: Option<Duration>) -> Result<reqwest::Client> {
    let mut builder = reqwest::Client::builder().user_agent(format!("fastforge/{CURRENT_VERSION}"));
    if let Some(timeout) = timeout {
        builder = builder.timeout(timeout);
    }
    builder.build().context("failed to create HTTP client")
}

/// Fetches the highest published (non-draft, non-prerelease) release that
/// ships a prebuilt binary for this platform. Releases from the Dart era
/// carry no binaries and are skipped.
pub async fn fetch_latest_release(client: &reqwest::Client) -> Result<Option<Release>> {
    let url = format!("https://api.github.com/repos/{REPO}/releases?per_page=100");
    let mut request = client
        .get(&url)
        .header("Accept", "application/vnd.github+json");
    if let Some(token) = std::env::var("GITHUB_TOKEN").ok().filter(|t| !t.is_empty()) {
        request = request.bearer_auth(token);
    }
    let response = request
        .send()
        .await
        .with_context(|| format!("failed to query {url}"))?;
    let status = response.status();
    if !status.is_success() {
        return Err(anyhow!("GET {url} returned {status}"));
    }
    let releases = response
        .json::<Vec<Release>>()
        .await
        .context("failed to parse the release list")?;
    Ok(releases
        .into_iter()
        .filter(|release| !release.draft && !release.prerelease)
        .filter(|release| release.platform_asset().is_some())
        .reduce(|best, release| {
            if is_newer(release.version(), best.version()) {
                release
            } else {
                best
            }
        }))
}

pub async fn check_version(client: &reqwest::Client) -> Result<CheckVersionResult> {
    let release = fetch_latest_release(client).await?;
    Ok(CheckVersionResult {
        current_version: CURRENT_VERSION.to_string(),
        latest_version: release.map(|release| release.version().to_string()),
    })
}

/// Compares dotted versions numerically (`0.10.0` > `0.9.0`). A pre-release
/// suffix (`1.0.0-beta`) sorts before the corresponding release.
pub fn is_newer(candidate: &str, current: &str) -> bool {
    fn parse(version: &str) -> (Vec<u64>, bool) {
        let version = version.trim().trim_start_matches('v');
        let version = version.split('+').next().unwrap_or_default();
        let (core, pre) = match version.split_once('-') {
            Some((core, _)) => (core, true),
            None => (version, false),
        };
        let parts = core
            .split('.')
            .map(|part| part.parse::<u64>().unwrap_or(0))
            .collect();
        (parts, pre)
    }
    let (candidate_parts, candidate_pre) = parse(candidate);
    let (current_parts, current_pre) = parse(current);
    let len = candidate_parts.len().max(current_parts.len());
    for i in 0..len {
        let a = candidate_parts.get(i).copied().unwrap_or(0);
        let b = current_parts.get(i).copied().unwrap_or(0);
        if a != b {
            return a > b;
        }
    }
    current_pre && !candidate_pre
}

/// A minimal "dots" spinner on stderr (the Dart `shell_uikit` `Spinner`).
/// It draws nothing when stderr is not a terminal.
pub struct Spinner {
    running: Arc<AtomicBool>,
    handle: Option<JoinHandle<()>>,
}

impl Spinner {
    pub fn start(text: &str) -> Self {
        let running = Arc::new(AtomicBool::new(true));
        let handle = std::io::stderr().is_terminal().then(|| {
            let running = running.clone();
            let text = text.to_string();
            std::thread::spawn(move || {
                const FRAMES: [&str; 10] = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
                let mut index = 0;
                while running.load(Ordering::Relaxed) {
                    let mut stderr = std::io::stderr();
                    let _ = write!(stderr, "\r\x1b[36m{}\x1b[0m {}", FRAMES[index], text);
                    let _ = stderr.flush();
                    index = (index + 1) % FRAMES.len();
                    std::thread::sleep(Duration::from_millis(80));
                }
                let mut stderr = std::io::stderr();
                let _ = write!(stderr, "\r\x1b[2K");
                let _ = stderr.flush();
            })
        });
        Self { running, handle }
    }

    pub fn stop(mut self) {
        self.running.store(false, Ordering::Relaxed);
        if let Some(handle) = self.handle.take() {
            let _ = handle.join();
        }
    }
}

fn print_result(result: &CheckVersionResult) {
    if result.is_new_version_available() {
        eprintln!(
            "\x1b[1;93m🚀 New version of {DISPLAY_NAME} available! \x1b[0m\x1b[91m{}\x1b[0m\x1b[93m → \x1b[0m\x1b[1;92m{}\x1b[0m",
            result.current_version,
            result.latest_version.as_deref().unwrap_or_default(),
        );
        eprintln!("\x1b[93mUpdate with: \x1b[0m\x1b[1;36m\"fastforge upgrade\"\x1b[0m");
    } else {
        eprintln!(
            "\x1b[90m🎉 You are using the latest version \x1b[0m\x1b[1;90m({})\x1b[0m",
            result.current_version
        );
    }
}

/// The automatic check performed before every command. Failures are silent.
pub async fn run_startup_check() {
    let spinner = Spinner::start("Checking for updates...");
    let result = match http_client(Some(STARTUP_CHECK_TIMEOUT)) {
        Ok(client) => check_version(&client).await.ok(),
        Err(_) => None,
    };
    spinner.stop();
    if let Some(result) = result {
        print_result(&result);
        eprintln!();
    }
}

pub async fn execute(args: &VersionCheckArgs) -> Result<()> {
    if args.current_only {
        println!("{CURRENT_VERSION}");
        return Ok(());
    }
    let spinner = Spinner::start("Checking for updates...");
    let result = async {
        let client = http_client(Some(Duration::from_secs(30)))?;
        check_version(&client).await
    }
    .await;
    spinner.stop();
    print_result(&result?);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::is_newer;

    #[test]
    fn compares_versions_numerically() {
        assert!(is_newer("0.7.1", "0.7.0"));
        assert!(is_newer("0.10.0", "0.9.9"));
        assert!(is_newer("v1.0.0", "0.99.0"));
        assert!(is_newer("1.0.0", "1.0.0-beta.1"));
        assert!(!is_newer("0.7.0", "0.7.0"));
        assert!(!is_newer("0.6.9", "0.7.0"));
        assert!(!is_newer("1.0.0-beta.1", "1.0.0"));
        assert!(!is_newer("0.7", "0.7.0"));
    }
}
