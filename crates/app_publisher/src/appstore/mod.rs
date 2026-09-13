use crate::common::{argument_or_env, artifact_path, run_streaming, to_publish_error};
use fastforge_core::{
    AppPublisher, PublishConfig, PublishError, PublishProgressCallback, PublishResult,
};
use std::env;
use std::path::{Path, PathBuf};
use std::process::Command;

pub struct AppStorePublisher;

const PUBLISHER_NAME: &str = "appstore";
const ENV_APPSTORE_USERNAME: &str = "APPSTORE_USERNAME";
const ENV_APPSTORE_PASSWORD: &str = "APPSTORE_PASSWORD";
const ENV_APPSTORE_API_KEY: &str = "APPSTORE_APIKEY";
const ENV_APPSTORE_API_ISSUER: &str = "APPSTORE_APIISSUER";
const KEY_ID_ENV: &str = "APP_STORE_CONNECT_KEY_ID";
const ISSUER_ID_ENV: &str = "APP_STORE_CONNECT_ISSUER_ID";
const KEY_PATH_ENV: &str = "APP_STORE_CONNECT_KEY_PATH";
const APPSTORE_CONNECT_APPS_URL: &str = "https://appstoreconnect.apple.com/apps";
const ALTOOL_AUTH_DOC_URL: &str =
    "https://help.apple.com/asc/appsaltool/#/apdATD1E53-D1E1A1303-D1E53A1126";

impl AppPublisher for AppStorePublisher {
    fn new() -> Self {
        Self
    }

    fn name(&self) -> &str {
        PUBLISHER_NAME
    }

    fn is_supported_on_current_platform(&self) -> bool {
        cfg!(target_os = "macos")
    }

    fn perform_publish(
        &self,
        config: &PublishConfig,
        _on_progress: Option<&PublishProgressCallback>,
    ) -> Result<PublishResult, PublishError> {
        if !self.is_supported_on_current_platform() {
            return Err(PublishError::General(
                "AppStore publisher is only supported on macOS.".to_string(),
            ));
        }

        let artifact_path = artifact_path(config)?;
        let artifact_path = std::fs::canonicalize(artifact_path).map_err(|error| {
            PublishError::General(format!(
                "Artifact path does not exist or cannot be resolved: {artifact_path}: {error}"
            ))
        })?;
        let artifact_type = appstore_artifact_type(&artifact_path)?;
        let auth = AppStoreAuth::from_config(config)?;

        let mut command = Command::new("xcrun");
        let mut args = vec![
            "altool".to_string(),
            "--upload-app".to_string(),
            "--file".to_string(),
            artifact_path.display().to_string(),
            "--type".to_string(),
            artifact_type.to_string(),
        ];
        args.extend(auth.to_cli_args());

        let staged_key = auth.stage_key_file()?;
        if let Some(staged_key) = &staged_key {
            command.current_dir(&staged_key.work_dir);
        }

        let output = run_streaming(command.args(args)).map_err(to_publish_error)?;
        if !output.status.success() {
            return Err(PublishError::General(format!(
                "{} - Upload of appstore failed",
                output.code()
            )));
        }

        Ok(PublishResult {
            success: true,
            message: APPSTORE_CONNECT_APPS_URL.to_string(),
        })
    }
}

struct StagedKeyFile {
    work_dir: PathBuf,
}

impl Drop for StagedKeyFile {
    fn drop(&mut self) {
        let _ = std::fs::remove_dir_all(&self.work_dir);
    }
}

struct AppStoreAuth {
    username: Option<String>,
    password: Option<String>,
    key_id: Option<String>,
    issuer_id: Option<String>,
    key_path: Option<String>,
}

impl AppStoreAuth {
    fn from_config(config: &PublishConfig) -> Result<Self, PublishError> {
        let username = argument_or_env(config, &["username"], &[ENV_APPSTORE_USERNAME]);
        let password = argument_or_env(config, &["password"], &[ENV_APPSTORE_PASSWORD]);
        let key_id = argument_or_env(
            config,
            &["key-id", "api-key"],
            &[ENV_APPSTORE_API_KEY, KEY_ID_ENV],
        );
        let issuer_id = argument_or_env(
            config,
            &["issuer-id", "api-issuer"],
            &[ENV_APPSTORE_API_ISSUER, ISSUER_ID_ENV],
        );
        let key_path = argument_or_env(config, &["key-path"], &[KEY_PATH_ENV]);

        // Validation mirrors Dart's `PublishAppStoreConfig.parse`. With an
        // API key only `APPSTORE_APIKEY` & `APPSTORE_APIISSUER` are required:
        // altool finds `AuthKey_<id>.p8` in its default `private_keys`
        // folders. A key path is an optional extra.
        if !is_non_empty(&username)
            && !is_non_empty(&password)
            && !is_non_empty(&key_id)
            && !is_non_empty(&issuer_id)
        {
            return Err(PublishError::General(format!(
                "Missing `{ENV_APPSTORE_USERNAME}` & `{ENV_APPSTORE_PASSWORD}` | `{ENV_APPSTORE_API_KEY}` & `{ENV_APPSTORE_API_ISSUER}` environment variable. See:{ALTOOL_AUTH_DOC_URL}"
            )));
        }
        if is_non_empty(&username) ^ is_non_empty(&password) {
            return Err(PublishError::General(format!(
                "Missing `{ENV_APPSTORE_USERNAME}` & `{ENV_APPSTORE_PASSWORD}` environment variable. See:{ALTOOL_AUTH_DOC_URL}"
            )));
        }
        if is_non_empty(&key_id) ^ is_non_empty(&issuer_id) {
            return Err(PublishError::General(format!(
                "Missing `{ENV_APPSTORE_API_KEY}` & `{ENV_APPSTORE_API_ISSUER}` environment variable. See:{ALTOOL_AUTH_DOC_URL}"
            )));
        }

        Ok(Self {
            username,
            password,
            key_id,
            issuer_id,
            key_path,
        })
    }

    fn to_cli_args(&self) -> Vec<String> {
        let mut args = Vec::new();
        push_flag(&mut args, "--username", self.username.as_deref());
        push_flag(&mut args, "--password", self.password.as_deref());
        push_flag(&mut args, "--apiKey", self.key_id.as_deref());
        push_flag(&mut args, "--apiIssuer", self.issuer_id.as_deref());
        args
    }

    fn stage_key_file(&self) -> Result<Option<StagedKeyFile>, PublishError> {
        let (Some(key_id), Some(key_path)) = (&self.key_id, &self.key_path) else {
            return Ok(None);
        };

        let source = expand_tilde(key_path);
        if !source.is_file() {
            return Err(PublishError::General(format!(
                "{KEY_PATH_ENV} does not point to a readable file: {}",
                source.display()
            )));
        }

        let work_dir = env::temp_dir().join(format!(
            "fastforge-appstore-{}-{}",
            std::process::id(),
            unix_timestamp_millis()
        ));
        let key_dir = work_dir.join("private_keys");
        std::fs::create_dir_all(&key_dir).map_err(to_publish_error)?;

        let destination = key_dir.join(format!("AuthKey_{key_id}.p8"));
        std::fs::copy(&source, &destination).map_err(to_publish_error)?;

        Ok(Some(StagedKeyFile { work_dir }))
    }
}

fn appstore_artifact_type(path: &Path) -> Result<&'static str, PublishError> {
    let extension = path
        .extension()
        .and_then(|ext| ext.to_str())
        .ok_or_else(|| {
            PublishError::General(format!(
                "Cannot infer artifact type from file path: {}",
                path.display()
            ))
        })?;
    match extension {
        "ipa" => Ok("ios"),
        "pkg" => Ok("osx"),
        _ => Ok("osx"),
    }
}

fn is_non_empty(value: &Option<String>) -> bool {
    value.as_ref().is_some_and(|v| !v.trim().is_empty())
}

fn push_flag(args: &mut Vec<String>, flag: &str, value: Option<&str>) {
    if let Some(value) = value.filter(|v| !v.trim().is_empty()) {
        args.push(flag.to_string());
        args.push(value.to_string());
    }
}

fn expand_tilde(path: &str) -> PathBuf {
    if path == "~" {
        return env::var_os("HOME")
            .map(PathBuf::from)
            .unwrap_or_else(|| PathBuf::from(path));
    }
    if let Some(rest) = path.strip_prefix("~/")
        && let Some(home) = env::var_os("HOME")
    {
        return PathBuf::from(home).join(rest);
    }
    PathBuf::from(path)
}

fn unix_timestamp_millis() -> u128 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|duration| duration.as_millis())
        .unwrap_or(0)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn config_with(environment: &[(&str, &str)]) -> PublishConfig {
        PublishConfig {
            environment: environment
                .iter()
                .map(|(k, v)| (k.to_string(), v.to_string()))
                .collect(),
            ..Default::default()
        }
    }

    #[test]
    fn api_key_and_issuer_are_enough() {
        let auth = AppStoreAuth::from_config(&config_with(&[
            (ENV_APPSTORE_API_KEY, "KEYID"),
            (ENV_APPSTORE_API_ISSUER, "issuer"),
        ]))
        .unwrap();
        assert_eq!(
            auth.to_cli_args(),
            vec!["--apiKey", "KEYID", "--apiIssuer", "issuer"]
        );
        if auth.key_path.is_none() {
            assert!(auth.stage_key_file().unwrap().is_none());
        }
    }

    #[test]
    fn api_key_without_issuer_is_rejected() {
        if env::var(ENV_APPSTORE_API_ISSUER).is_ok() || env::var(ISSUER_ID_ENV).is_ok() {
            return;
        }
        let error = AppStoreAuth::from_config(&config_with(&[(ENV_APPSTORE_API_KEY, "KEYID")]))
            .err()
            .unwrap();
        assert_eq!(
            error.to_string(),
            format!(
                "Missing `APPSTORE_APIKEY` & `APPSTORE_APIISSUER` environment variable. See:{ALTOOL_AUTH_DOC_URL}"
            )
        );
    }
}
