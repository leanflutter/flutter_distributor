use std::collections::HashMap;

/// Reads environment variables on the host's behalf.
///
/// Injected rather than called directly: this crate compiles to `wasm32`, where
/// there is no process environment, and tests need a deterministic one.
pub trait EnvLookup {
    fn get(&self, key: &str) -> Option<String>;

    /// Whether a variable is set to something non-blank. A variable set to the
    /// empty string is treated as unset — it is a configuration mistake, not a
    /// credential.
    fn is_set(&self, key: &str) -> bool {
        self.get(key).is_some_and(|value| !value.trim().is_empty())
    }
}

/// An [`EnvLookup`] backed by a map, for tests and for hosts that carry their
/// own environment (a Worker's bindings, say).
#[derive(Debug, Clone, Default)]
pub struct MapEnv(HashMap<String, String>);

impl MapEnv {
    pub fn new<I, K, V>(entries: I) -> Self
    where
        I: IntoIterator<Item = (K, V)>,
        K: Into<String>,
        V: Into<String>,
    {
        Self(
            entries
                .into_iter()
                .map(|(key, value)| (key.into(), value.into()))
                .collect(),
        )
    }
}

impl EnvLookup for MapEnv {
    fn get(&self, key: &str) -> Option<String> {
        self.0.get(key).cloned()
    }
}

/// Extracts `NAME` from a `${NAME}` reference.
///
/// Matches fastforge's `resolve_env_ref`: the whole value must be the
/// reference, so a path like `${HOME}/keys` is a literal, not a reference.
pub fn env_ref_name(value: &str) -> Option<&str> {
    let name = value.strip_prefix("${")?.strip_suffix('}')?;
    (!name.is_empty()).then_some(name)
}

/// Where a credential field's value comes from. Never carries the value.
#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) enum FieldSource {
    /// A literal in `.fastforge/config.yaml`.
    Config,
    /// Resolved from this environment variable, either through a `${NAME}`
    /// reference or through fastforge's default variable list.
    Env(String),
    /// Nothing supplies it.
    Unset,
}

/// Resolves one credential field the way fastforge does: `${NAME}` references
/// first, then the literal, then the default environment variables that
/// `apply_env_defaults` would consult.
pub(crate) fn resolve_field(
    value: Option<&str>,
    default_env_keys: &[&str],
    env: &dyn EnvLookup,
) -> FieldSource {
    if let Some(value) = value.map(str::trim).filter(|value| !value.is_empty()) {
        if let Some(name) = env_ref_name(value) {
            return if env.is_set(name) {
                FieldSource::Env(name.to_owned())
            } else {
                // fastforge leaves the unresolved `${NAME}` in place, so the
                // field is present but unusable.
                FieldSource::Unset
            };
        }
        return FieldSource::Config;
    }

    default_env_keys
        .iter()
        .find(|key| env.is_set(key))
        .map(|key| FieldSource::Env((*key).to_owned()))
        .unwrap_or(FieldSource::Unset)
}

/// Default environment variables, mirroring `apply_env_defaults` in
/// `fastforge_cli::config`. Order matters: the first set variable wins.
pub(crate) mod defaults {
    pub const APPSTORE_KEY_ID: &[&str] = &["APP_STORE_CONNECT_KEY_ID", "APPSTORE_APIKEY"];
    pub const APPSTORE_ISSUER_ID: &[&str] = &["APP_STORE_CONNECT_ISSUER_ID", "APPSTORE_APIISSUER"];
    pub const APPSTORE_KEY_PATH: &[&str] = &["APP_STORE_CONNECT_KEY_PATH"];
    pub const APPSTORE_USERNAME: &[&str] = &["APPSTORE_USERNAME"];
    pub const APPSTORE_PASSWORD: &[&str] = &["APPSTORE_PASSWORD"];
    pub const GOOGLEPLAY_SERVICE_ACCOUNT_KEY: &[&str] = &[
        "GOOGLE_PLAY_SERVICE_ACCOUNT_KEY",
        "GOOGLE_APPLICATION_CREDENTIALS",
    ];
    pub const GOOGLEPLAY_SERVICE_ACCOUNT_JSON: &[&str] = &["GOOGLE_PLAY_SERVICE_ACCOUNT_JSON"];
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn env_refs_must_be_the_whole_value() {
        assert_eq!(env_ref_name("${KEY_ID}"), Some("KEY_ID"));
        assert_eq!(env_ref_name("${}"), None);
        assert_eq!(env_ref_name("${HOME}/keys/AuthKey.p8"), None);
        assert_eq!(env_ref_name("plain"), None);
    }

    #[test]
    fn a_literal_resolves_from_config() {
        let env = MapEnv::default();
        assert_eq!(
            resolve_field(Some("ABC123"), defaults::APPSTORE_KEY_ID, &env),
            FieldSource::Config
        );
    }

    #[test]
    fn an_env_ref_resolves_only_when_the_variable_is_set() {
        let env = MapEnv::new([("MY_KEY", "value")]);
        assert_eq!(
            resolve_field(Some("${MY_KEY}"), &[], &env),
            FieldSource::Env("MY_KEY".into())
        );
        assert_eq!(
            resolve_field(Some("${MISSING}"), &[], &env),
            FieldSource::Unset
        );
    }

    #[test]
    fn a_blank_variable_counts_as_unset() {
        let env = MapEnv::new([("MY_KEY", "   ")]);
        assert_eq!(
            resolve_field(Some("${MY_KEY}"), &[], &env),
            FieldSource::Unset
        );
    }

    #[test]
    fn defaults_apply_in_order_when_config_is_silent() {
        let env = MapEnv::new([("APPSTORE_APIKEY", "legacy")]);
        assert_eq!(
            resolve_field(None, defaults::APPSTORE_KEY_ID, &env),
            FieldSource::Env("APPSTORE_APIKEY".into())
        );

        let both = MapEnv::new([
            ("APP_STORE_CONNECT_KEY_ID", "new"),
            ("APPSTORE_APIKEY", "legacy"),
        ]);
        assert_eq!(
            resolve_field(None, defaults::APPSTORE_KEY_ID, &both),
            FieldSource::Env("APP_STORE_CONNECT_KEY_ID".into())
        );
    }

    #[test]
    fn nothing_anywhere_is_unset() {
        assert_eq!(
            resolve_field(Some("  "), defaults::APPSTORE_KEY_PATH, &MapEnv::default()),
            FieldSource::Unset
        );
    }
}
