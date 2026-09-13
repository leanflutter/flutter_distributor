use crate::common::{argument_or_env, artifact_path, extract_url_after, run_streaming};
use fastforge_core::{
    AppPublisher, PublishConfig, PublishError, PublishProgressCallback, PublishResult,
};
use serde_json::json;
use std::fs;
use std::path::Path;
use std::process::Command;

pub struct FirebaseHostingPublisher;

const PUBLISHER_NAME: &str = "firebase-hosting";
const ENV_FIREBASE_TOKEN: &str = "FIREBASE_TOKEN";
const ENV_FIREBASE_PROJECT_ID: &str = "FIREBASE_PROJECT_ID";

impl AppPublisher for FirebaseHostingPublisher {
    fn new() -> Self {
        Self
    }

    fn name(&self) -> &str {
        PUBLISHER_NAME
    }

    fn is_supported_on_current_platform(&self) -> bool {
        true
    }

    fn perform_publish(
        &self,
        config: &PublishConfig,
        _on_progress: Option<&PublishProgressCallback>,
    ) -> Result<PublishResult, PublishError> {
        let artifact_path = artifact_path(config)?;
        let project_id = argument_or_env(
            config,
            &["project-id", "firebase-project-id"],
            &[ENV_FIREBASE_PROJECT_ID],
        )
        .ok_or_else(|| PublishError::General("Missing `project-id` config.".to_string()))?;

        let directory = Path::new(artifact_path);
        fs::create_dir_all(directory)?;
        let firebaserc = json!({ "projects": { "default": project_id } });
        fs::write(directory.join(".firebaserc"), firebaserc.to_string())
            .map_err(|e| PublishError::General(format!("Failed to write .firebaserc: {e}")))?;
        let firebase_json = json!({
            "hosting": { "public": ".", "ignore": ["firebase.json"] }
        });
        fs::write(directory.join("firebase.json"), firebase_json.to_string())
            .map_err(|e| PublishError::General(format!("Failed to write firebase.json: {e}")))?;

        let mut cmd = Command::new("firebase");
        cmd.arg("deploy").current_dir(artifact_path);
        // Rust extra: pass `FIREBASE_TOKEN` when available.
        if let Some(token) = config.env_var(ENV_FIREBASE_TOKEN) {
            cmd.arg("--token").arg(token);
        }

        let output = run_streaming(&mut cmd)
            .map_err(|e| PublishError::CommandFailed(format!("Failed to run firebase CLI: {e}")))?;
        if !output.status.success() {
            return Err(PublishError::CommandFailed(format!(
                "firebase deploy failed ({})",
                output.code()
            )));
        }

        // Dart: `(?<=Hosting URL: )\bhttps?:\/\/\S+\b` on stdout, '' when absent.
        let url = extract_url_after(&output.stdout, "Hosting URL: ").unwrap_or_default();
        Ok(PublishResult {
            success: true,
            message: url,
        })
    }
}
