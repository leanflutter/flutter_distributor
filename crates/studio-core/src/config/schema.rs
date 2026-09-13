use serde::{Deserialize, Serialize};

/// Parsed contents of `.fastforge/config.yaml`.
///
/// Field names match `fastforge_cli::config` exactly — the same file is read by
/// both, and a Studio round-trip must leave `fastforge store list` working.
/// Unknown sections are preserved by the host's order-preserving writer, not by
/// this type, which only models what Studio understands.
#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct FastforgeConfig {
    #[serde(default)]
    pub stores: StoresConfig,
}

impl FastforgeConfig {
    pub const DEFAULT_PATH: &'static str = ".fastforge/config.yaml";

    pub fn parse(content: &str) -> Result<Self, serde_yaml::Error> {
        // An empty file is a valid, empty config rather than a parse error.
        if content.trim().is_empty() {
            return Ok(Self::default());
        }
        serde_yaml::from_str(content)
    }
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct StoresConfig {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub appstore: Option<AppStoreConfig>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub googleplay: Option<GooglePlayConfig>,
}

impl StoresConfig {
    pub fn is_empty(&self) -> bool {
        self.appstore.is_none() && self.googleplay.is_none()
    }
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct AppStoreConfig {
    #[serde(default)]
    pub auth: AppStoreAuthConfig,
    #[serde(default)]
    pub apps: Vec<AppStoreApp>,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct AppStoreAuthConfig {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub key_id: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub issuer_id: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub key_path: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub username: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub password: Option<String>,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct AppStoreApp {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub bundle_id: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub app_id: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub sku: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
}

impl AppStoreApp {
    /// Catalog commands key off `bundle_id`; `app_id` is the fallback fastforge
    /// itself uses when building catalog targets.
    pub fn identifier(&self) -> Option<&str> {
        non_empty(self.bundle_id.as_deref()).or_else(|| non_empty(self.app_id.as_deref()))
    }
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct GooglePlayConfig {
    #[serde(default)]
    pub auth: GooglePlayAuthConfig,
    #[serde(default)]
    pub apps: Vec<GooglePlayApp>,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct GooglePlayAuthConfig {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub service_account_key: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub service_account_json: Option<String>,
}

#[derive(Debug, Clone, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct GooglePlayApp {
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub package_name: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub track: Option<String>,
}

impl GooglePlayApp {
    pub fn identifier(&self) -> Option<&str> {
        non_empty(self.package_name.as_deref())
    }
}

pub(crate) fn non_empty(value: Option<&str>) -> Option<&str> {
    value.filter(|value| !value.trim().is_empty())
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE: &str = r#"
stores:
  appstore:
    auth:
      key_id: configured-key-id
      issuer_id: issuer
      key_path: ./AuthKey.p8
    apps:
      - bundle_id: com.example.myapp
        app_id: "1234567890"
        sku: MYAPP001
        name: My App
  googleplay:
    auth:
      service_account_key: ./service-account.json
    apps:
      - package_name: com.example.myapp
        track: production
"#;

    #[test]
    fn parses_the_documented_stores_section() {
        let config = FastforgeConfig::parse(SAMPLE).unwrap();
        let appstore = config.stores.appstore.as_ref().unwrap();
        assert_eq!(appstore.auth.issuer_id.as_deref(), Some("issuer"));
        assert_eq!(appstore.apps[0].identifier(), Some("com.example.myapp"));
        assert_eq!(appstore.apps[0].sku.as_deref(), Some("MYAPP001"));

        let googleplay = config.stores.googleplay.as_ref().unwrap();
        assert_eq!(googleplay.apps[0].identifier(), Some("com.example.myapp"));
        assert_eq!(googleplay.apps[0].track.as_deref(), Some("production"));
    }

    #[test]
    fn an_empty_file_is_an_empty_config() {
        assert_eq!(
            FastforgeConfig::parse("").unwrap(),
            FastforgeConfig::default()
        );
        assert_eq!(
            FastforgeConfig::parse("\n  \n").unwrap(),
            FastforgeConfig::default()
        );
        assert!(FastforgeConfig::default().stores.is_empty());
    }

    #[test]
    fn auth_may_be_omitted_entirely() {
        let config = FastforgeConfig::parse(
            r#"
stores:
  appstore:
    apps:
      - bundle_id: com.example.myapp
"#,
        )
        .unwrap();
        let appstore = config.stores.appstore.as_ref().unwrap();
        assert_eq!(appstore.auth, AppStoreAuthConfig::default());
        assert_eq!(appstore.apps[0].identifier(), Some("com.example.myapp"));
    }

    #[test]
    fn identifier_falls_back_to_app_id_like_fastforge_does() {
        let app = AppStoreApp {
            bundle_id: None,
            app_id: Some("456".into()),
            ..Default::default()
        };
        assert_eq!(app.identifier(), Some("456"));

        let blank = AppStoreApp {
            bundle_id: Some("  ".into()),
            app_id: Some("456".into()),
            ..Default::default()
        };
        assert_eq!(blank.identifier(), Some("456"));

        assert_eq!(AppStoreApp::default().identifier(), None);
    }
}
