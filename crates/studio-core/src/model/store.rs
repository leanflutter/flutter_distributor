use serde::{Deserialize, Serialize};

use super::catalog::CatalogState;
use super::project::Platform;

/// Stores go beyond uploading a single artifact: they own the listing, its
/// versions and its review state. Fastforge supports two today.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum StoreKind {
    #[serde(rename = "appstore")]
    AppStore,
    #[serde(rename = "googleplay")]
    GooglePlay,
}

impl StoreKind {
    pub const ALL: [StoreKind; 2] = [StoreKind::AppStore, StoreKind::GooglePlay];

    pub fn as_str(self) -> &'static str {
        match self {
            StoreKind::AppStore => "appstore",
            StoreKind::GooglePlay => "googleplay",
        }
    }

    pub fn label(self) -> &'static str {
        match self {
            StoreKind::AppStore => "App Store Connect",
            StoreKind::GooglePlay => "Google Play Console",
        }
    }

    pub fn description(self) -> &'static str {
        match self {
            StoreKind::AppStore => "Builds, versions, TestFlight and review submissions.",
            StoreKind::GooglePlay => "Edits, AAB uploads and release tracks.",
        }
    }

    /// The platform whose artifacts this store accepts. Used to tag store apps
    /// so the UI can group them the same way it groups projects.
    pub fn platform(self) -> Platform {
        match self {
            StoreKind::AppStore => Platform::Ios,
            StoreKind::GooglePlay => Platform::Android,
        }
    }

    /// The identifier field's name in `.fastforge/config.yaml`, used in error
    /// messages so they point at the field the user actually has to edit.
    pub fn identifier_field(self) -> &'static str {
        match self {
            StoreKind::AppStore => "bundle_id",
            StoreKind::GooglePlay => "package_name",
        }
    }

    pub fn parse(value: &str) -> Option<StoreKind> {
        StoreKind::ALL
            .into_iter()
            .find(|kind| kind.as_str() == value)
    }
}

/// How a store authenticates. Mirrors `auth_type()` in fastforge's config.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum AuthType {
    ApiKey,
    UsernamePassword,
    ServiceAccount,
    Unknown,
}

impl AuthType {
    pub fn as_str(self) -> &'static str {
        match self {
            AuthType::ApiKey => "api_key",
            AuthType::UsernamePassword => "username_password",
            AuthType::ServiceAccount => "service_account",
            AuthType::Unknown => "unknown",
        }
    }
}

/// Whether the credentials a store needs are actually resolvable.
///
/// Studio never reads credential *values* — it only reports whether each field
/// resolves, and from where. That is the whole reason this round needs no
/// secret storage of its own.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "state", rename_all = "camelCase")]
pub enum AuthStatus {
    /// Every required field resolves.
    Ready {
        /// Field name → where the value came from, e.g. `"config"` or
        /// `"env:APP_STORE_CONNECT_KEY_ID"`. Never the value itself.
        #[serde(default)]
        sources: Vec<AuthFieldSource>,
    },
    /// At least one required field is missing or points at an unset variable.
    Incomplete { missing: Vec<AuthFieldSource> },
    /// The store has no section in `.fastforge/config.yaml` at all.
    NotConfigured,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AuthFieldSource {
    /// Config field name, e.g. `key_id`.
    pub field: String,
    /// `config`, `env:NAME`, or `unset` — never a credential value.
    pub source: String,
    /// Environment variables that would satisfy this field when it is missing.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub candidates: Vec<String>,
}

impl AuthFieldSource {
    pub fn from_config(field: &str) -> Self {
        Self {
            field: field.to_owned(),
            source: "config".to_owned(),
            candidates: Vec::new(),
        }
    }

    pub fn from_env(field: &str, key: &str) -> Self {
        Self {
            field: field.to_owned(),
            source: format!("env:{key}"),
            candidates: Vec::new(),
        }
    }

    pub fn unset(field: &str, candidates: &[&str]) -> Self {
        Self {
            field: field.to_owned(),
            source: "unset".to_owned(),
            candidates: candidates.iter().map(|key| (*key).to_owned()).collect(),
        }
    }
}

/// A store as configured for one project.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct StoreConnection {
    pub store: StoreKind,
    pub name: String,
    pub description: String,
    /// Whether `.fastforge/config.yaml` has a section for this store.
    pub configured: bool,
    pub auth_type: AuthType,
    pub auth_status: AuthStatus,
    pub app_count: usize,
}

/// One app registered under a store.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct StoreApp {
    /// `"<store>:<identifier>"`. Fills the `$storeAppId` route segment, and
    /// stays unique when one project ships several bundles.
    pub id: String,
    pub store: StoreKind,
    /// `bundle_id` for App Store, `package_name` for Google Play.
    pub identifier: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub app_id: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub sku: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub track: Option<String>,
    pub platform: Platform,
    pub catalog: CatalogState,
}

/// Builds the composite id used in URLs.
pub fn store_app_id(store: StoreKind, identifier: &str) -> String {
    format!("{}:{}", store.as_str(), identifier)
}

/// Splits a composite id back apart. Returns `None` when the store segment is
/// unknown or the identifier is empty, so callers can answer 404 rather than
/// searching for something that can never exist.
pub fn parse_store_app_id(value: &str) -> Option<(StoreKind, &str)> {
    let (store, identifier) = value.split_once(':')?;
    if identifier.is_empty() {
        return None;
    }
    Some((StoreKind::parse(store)?, identifier))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn store_app_id_round_trips() {
        let id = store_app_id(StoreKind::AppStore, "com.example.myapp");
        assert_eq!(id, "appstore:com.example.myapp");
        assert_eq!(
            parse_store_app_id(&id),
            Some((StoreKind::AppStore, "com.example.myapp"))
        );
    }

    #[test]
    fn store_app_id_rejects_unknown_and_empty() {
        assert_eq!(parse_store_app_id("steam:com.example"), None);
        assert_eq!(parse_store_app_id("appstore:"), None);
        assert_eq!(parse_store_app_id("appstore"), None);
    }

    #[test]
    fn store_kind_uses_the_config_yaml_spelling() {
        assert_eq!(
            serde_json::to_value(StoreKind::GooglePlay).unwrap(),
            serde_json::json!("googleplay")
        );
        assert_eq!(StoreKind::parse("googleplay"), Some(StoreKind::GooglePlay));
    }

    #[test]
    fn auth_status_is_tagged_for_the_client() {
        let value = serde_json::to_value(AuthStatus::Incomplete {
            missing: vec![AuthFieldSource::unset(
                "key_id",
                &["APP_STORE_CONNECT_KEY_ID"],
            )],
        })
        .unwrap();
        assert_eq!(value["state"], serde_json::json!("incomplete"));
        assert_eq!(value["missing"][0]["field"], serde_json::json!("key_id"));
        assert_eq!(value["missing"][0]["source"], serde_json::json!("unset"));
    }
}
