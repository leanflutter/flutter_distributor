//! Qiniu Kodo publisher using Qiniu's native form upload, like Dart's
//! `AppPackagePublisherQiniu` (qiniu_sdk_base).

use crate::common::{
    argument, argument_or_env, artifact_path, file_name, file_part, http_client, missing_env,
    to_publish_error,
};
use base64::Engine;
use base64::engine::general_purpose::URL_SAFE;
use fastforge_core::{
    AppPublisher, PublishConfig, PublishError, PublishProgressCallback, PublishResult,
};
use hmac::{Hmac, Mac};
use reqwest::blocking::Client;
use reqwest::blocking::multipart::Form;
use serde_json::{Value, json};
use sha1::Sha1;

pub struct QiniuPublisher;

const PUBLISHER_NAME: &str = "qiniu";
const ENV_QINIU_ACCESS_KEY: &str = "QINIU_ACCESS_KEY";
const ENV_QINIU_SECRET_KEY: &str = "QINIU_SECRET_KEY";
const ENV_QINIU_BUCKET: &str = "QINIU_BUCKET";
const ENV_QINIU_PUBLIC_BASE_URL: &str = "QINIU_PUBLIC_BASE_URL";
const UC_QUERY_URL: &str = "https://uc.qbox.me/v4/query";
const DEFAULT_UPLOAD_HOST: &str = "https://upload.qiniup.com";
const UPLOAD_TOKEN_TTL_SECS: i64 = 3600;

type HmacSha1 = Hmac<Sha1>;

/// Mirrors Dart's `PublishQiniuConfig`.
struct QiniuConfig {
    access_key: String,
    secret_key: String,
    bucket: String,
    bucket_domain: Option<String>,
    savekey_prefix: String,
}

impl QiniuConfig {
    fn parse(config: &PublishConfig) -> Result<Self, PublishError> {
        let access_key = argument_or_env(
            config,
            &["access-key", "qiniu-access-key"],
            &[ENV_QINIU_ACCESS_KEY],
        )
        .ok_or_else(|| missing_env(ENV_QINIU_ACCESS_KEY))?;
        let secret_key = argument_or_env(
            config,
            &["secret-key", "qiniu-secret-key"],
            &[ENV_QINIU_SECRET_KEY],
        )
        .ok_or_else(|| missing_env(ENV_QINIU_SECRET_KEY))?;
        let bucket = argument_or_env(config, &["bucket", "qiniu-bucket"], &[ENV_QINIU_BUCKET])
            .ok_or_else(|| {
                PublishError::General(
                    "Qiniu bucket is required. Please provide it via `--qiniu-bucket` argument."
                        .to_string(),
                )
            })?;
        // Dart keeps an empty `bucket-domain` as-is (-> `/<key>`).
        let bucket_domain = config
            .publish_arguments
            .as_ref()
            .and_then(|arguments| arguments.get("bucket-domain").cloned())
            .or_else(|| argument(config, &["public-base-url", "qiniu-public-base-url"]))
            .or_else(|| config.env_var(ENV_QINIU_PUBLIC_BASE_URL));
        let savekey_prefix = config
            .publish_arguments
            .as_ref()
            .and_then(|arguments| {
                arguments
                    .get("savekey-prefix")
                    .or_else(|| arguments.get("key-prefix"))
                    .cloned()
            })
            .unwrap_or_default();

        Ok(Self {
            access_key,
            secret_key,
            bucket,
            bucket_domain,
            savekey_prefix,
        })
    }
}

impl AppPublisher for QiniuPublisher {
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
        on_progress: Option<&PublishProgressCallback>,
    ) -> Result<PublishResult, PublishError> {
        let artifact_path = artifact_path(config)?;
        let qiniu_config = QiniuConfig::parse(config)?;
        let file_name = file_name(artifact_path)?;

        // Dart: `'${savekeyPrefix}${fileName}'` (plain concatenation).
        let save_key = format!("{}{}", qiniu_config.savekey_prefix, file_name);
        let deadline = chrono::Utc::now().timestamp() + UPLOAD_TOKEN_TTL_SECS;
        let put_policy = json!({
            "scope": qiniu_config.bucket,
            "deadline": deadline,
            "saveKey": save_key,
        });
        let upload_token = upload_token(
            &qiniu_config.access_key,
            &qiniu_config.secret_key,
            &put_policy.to_string(),
        )?;

        let client = http_client()?;
        let upload_host =
            query_upload_host(&client, &qiniu_config.access_key, &qiniu_config.bucket);
        // Like Dart's `Storage.putFile` without a key: the object is stored
        // under the policy's `saveKey`, and the response reports the key.
        let form = Form::new()
            .text("token", upload_token)
            .part("file", file_part(artifact_path, &file_name, on_progress)?);
        let response = client
            .post(&upload_host)
            .multipart(form)
            .send()
            .map_err(to_publish_error)?;
        let status = response.status();
        let text = response.text().map_err(to_publish_error)?;
        let body: Value = serde_json::from_str(&text).unwrap_or(Value::Null);
        if !status.is_success() {
            let message = body
                .get("error")
                .and_then(Value::as_str)
                .map(ToOwned::to_owned)
                .unwrap_or(text);
            return Err(PublishError::General(format!(
                "{} - {message}",
                status.as_u16()
            )));
        }
        let key = body
            .get("key")
            .and_then(Value::as_str)
            .map(ToOwned::to_owned)
            .unwrap_or(save_key);

        Ok(PublishResult {
            success: true,
            message: public_url(qiniu_config.bucket_domain.as_deref(), &key),
        })
    }
}

/// `AK:urlsafe_b64(hmac_sha1(SK, encodedPutPolicy)):encodedPutPolicy`
fn upload_token(
    access_key: &str,
    secret_key: &str,
    put_policy: &str,
) -> Result<String, PublishError> {
    let encoded_policy = URL_SAFE.encode(put_policy.as_bytes());
    let mut mac = HmacSha1::new_from_slice(secret_key.as_bytes()).map_err(to_publish_error)?;
    mac.update(encoded_policy.as_bytes());
    let encoded_sign = URL_SAFE.encode(mac.finalize().into_bytes());
    Ok(format!("{access_key}:{encoded_sign}:{encoded_policy}"))
}

/// Resolves the bucket's upload host (Dart's SDK auto-selects the region).
fn query_upload_host(client: &Client, access_key: &str, bucket: &str) -> String {
    let body = client
        .get(UC_QUERY_URL)
        .query(&[("ak", access_key), ("bucket", bucket)])
        .send()
        .ok()
        .filter(|response| response.status().is_success())
        .and_then(|response| response.json::<Value>().ok());
    body.as_ref()
        .and_then(upload_host_from_query)
        .unwrap_or_else(|| DEFAULT_UPLOAD_HOST.to_string())
}

fn upload_host_from_query(body: &Value) -> Option<String> {
    let up = body.get("hosts")?.as_array()?.first()?.get("up")?;
    let domain = up
        .get("domains")
        .and_then(|domains| domains.as_array()?.first()?.as_str())
        // Older (v2/v3) response shape.
        .or_else(|| up.get("acc")?.get("main")?.as_array()?.first()?.as_str())?;
    if domain.starts_with("http://") || domain.starts_with("https://") {
        Some(domain.to_string())
    } else {
        Some(format!("https://{domain}"))
    }
}

/// Dart: `'${bucketDomain ?? '<bucketDomain>'}/${key}'`, without encoding.
fn public_url(bucket_domain: Option<&str>, key: &str) -> String {
    format!("{}/{key}", bucket_domain.unwrap_or("<bucketDomain>"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn upload_token_matches_qiniu_documentation_example() {
        // Example from Qiniu's upload token documentation.
        let policy = r#"{"scope":"my-bucket:sunflower.jpg","deadline":1451491200,"returnBody":"{\"name\":$(fname),\"size\":$(fsize),\"w\":$(imageInfo.width),\"h\":$(imageInfo.height),\"hash\":$(etag)}"}"#;
        let token = upload_token("MY_ACCESS_KEY", "MY_SECRET_KEY", policy).unwrap();
        assert_eq!(
            token,
            "MY_ACCESS_KEY:wQ4ofysef1R7IKnrziqtomqyDvI=:eyJzY29wZSI6Im15LWJ1Y2tldDpzdW5mbG93ZXIuanBnIiwiZGVhZGxpbmUiOjE0NTE0OTEyMDAsInJldHVybkJvZHkiOiJ7XCJuYW1lXCI6JChmbmFtZSksXCJzaXplXCI6JChmc2l6ZSksXCJ3XCI6JChpbWFnZUluZm8ud2lkdGgpLFwiaFwiOiQoaW1hZ2VJbmZvLmhlaWdodCksXCJoYXNoXCI6JChldGFnKX0ifQ=="
        );
    }

    #[test]
    fn upload_host_supports_v4_and_legacy_shapes() {
        let v4 = json!({"hosts": [{"region": "z0", "up": {"domains": ["upload.qiniup.com", "up.qiniup.com"]}}]});
        assert_eq!(
            upload_host_from_query(&v4).as_deref(),
            Some("https://upload.qiniup.com")
        );
        let legacy = json!({"hosts": [{"up": {"acc": {"main": ["upload-z2.qiniup.com"]}}}]});
        assert_eq!(
            upload_host_from_query(&legacy).as_deref(),
            Some("https://upload-z2.qiniup.com")
        );
        assert_eq!(upload_host_from_query(&json!({})), None);
    }

    #[test]
    fn public_url_matches_dart() {
        assert_eq!(
            public_url(Some("https://cdn.example.com"), "apps/my app.apk"),
            "https://cdn.example.com/apps/my app.apk"
        );
        assert_eq!(public_url(None, "app.apk"), "<bucketDomain>/app.apk");
    }

    #[test]
    fn save_key_is_plain_concatenation() {
        let config = PublishConfig {
            publish_arguments: Some(
                [
                    ("bucket".to_string(), "b".to_string()),
                    ("savekey-prefix".to_string(), "release-".to_string()),
                ]
                .into(),
            ),
            environment: [
                (ENV_QINIU_ACCESS_KEY.to_string(), "ak".to_string()),
                (ENV_QINIU_SECRET_KEY.to_string(), "sk".to_string()),
            ]
            .into(),
            ..Default::default()
        };
        let parsed = QiniuConfig::parse(&config).unwrap();
        assert_eq!(
            format!("{}{}", parsed.savekey_prefix, "app.apk"),
            "release-app.apk"
        );
    }
}
