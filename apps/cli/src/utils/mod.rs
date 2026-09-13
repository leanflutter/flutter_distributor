//! Console output and process helpers shared by the commands, mirroring the
//! Dart CLI's `logger` + `DefaultShellExecutor`.

use std::collections::HashMap;
use std::io::{BufRead, BufReader, Write};
use std::process::{Command, ExitStatus, Stdio};

use anyhow::{Result, anyhow};

use crate::config::DistributeOptions;

pub fn bright_green(text: &str) -> String {
    format!("\x1b[92m{text}\x1b[0m")
}

pub fn yellow(text: &str) -> String {
    format!("\x1b[33m{text}\x1b[0m")
}

pub fn bright_black(text: &str) -> String {
    format!("\x1b[90m{text}\x1b[0m")
}

/// Dart's `UnifiedDistributor.globalVariables`: the non-empty process
/// environment overlaid with the non-empty `distribute_options.yaml`
/// variables.
pub fn global_variables(options: &DistributeOptions) -> HashMap<String, String> {
    let mut variables: HashMap<String, String> =
        std::env::vars().filter(|(_, v)| !v.is_empty()).collect();
    variables.extend(
        options
            .resolved_variables()
            .into_iter()
            .filter(|(_, v)| !v.is_empty()),
    );
    variables
}

/// Runs `command`, echoing `$ <echo>` first and streaming its output, like
/// Dart's `DefaultShellExecutor.exec`. Returns the exit status and the
/// captured stderr.
pub fn run_streaming(command: &mut Command, echo: &str) -> Result<(ExitStatus, String)> {
    eprintln!("{}", bright_black(&format!("$ {echo}")));
    let mut child = command
        .stdout(Stdio::inherit())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| anyhow!("Failed to execute `{echo}`: {e}"))?;
    let mut captured = String::new();
    if let Some(stderr) = child.stderr.take() {
        let mut reader = BufReader::new(stderr);
        let mut line = Vec::new();
        let mut sink = std::io::stderr();
        while reader.read_until(b'\n', &mut line).unwrap_or(0) > 0 {
            let _ = sink.write_all(&line);
            let _ = sink.flush();
            captured.push_str(&String::from_utf8_lossy(&line));
            line.clear();
        }
    }
    let status = child
        .wait()
        .map_err(|e| anyhow!("Failed to execute `{echo}`: {e}"))?;
    Ok((status, captured))
}
