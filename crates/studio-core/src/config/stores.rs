use super::env_ref::{EnvLookup, FieldSource, defaults, resolve_field};
use super::schema::{AppStoreAuthConfig, FastforgeConfig, GooglePlayAuthConfig};
use crate::model::{
    AuthFieldSource, AuthStatus, AuthType, CatalogState, StoreApp, StoreConnection, StoreKind,
    store_app_id,
};

/// Both supported stores, configured or not.
///
/// Unconfigured stores are returned too: the stores page lists what a project
/// *could* connect to, and hiding them would leave the page empty for a project
/// that has not been set up yet — which is exactly when it is most useful.
pub fn store_connections(config: &FastforgeConfig, env: &dyn EnvLookup) -> Vec<StoreConnection> {
    StoreKind::ALL
        .into_iter()
        .map(|store| store_connection(config, store, env))
        .collect()
}

pub fn store_connection(
    config: &FastforgeConfig,
    store: StoreKind,
    env: &dyn EnvLookup,
) -> StoreConnection {
    let (configured, auth_type, auth_status, app_count) = match store {
        StoreKind::AppStore => match config.stores.appstore.as_ref() {
            Some(appstore) => {
                let (auth_type, auth_status) = evaluate_appstore_auth(&appstore.auth, env);
                (true, auth_type, auth_status, appstore.apps.len())
            }
            None => (false, AuthType::Unknown, AuthStatus::NotConfigured, 0),
        },
        StoreKind::GooglePlay => match config.stores.googleplay.as_ref() {
            Some(googleplay) => {
                let (auth_type, auth_status) = evaluate_googleplay_auth(&googleplay.auth, env);
                (true, auth_type, auth_status, googleplay.apps.len())
            }
            None => (false, AuthType::Unknown, AuthStatus::NotConfigured, 0),
        },
    };

    StoreConnection {
        store,
        name: store.label().to_owned(),
        description: store.description().to_owned(),
        configured,
        auth_type,
        auth_status,
        app_count,
    }
}

/// Every app registered across both stores, in configuration order.
///
/// The returned [`StoreApp::catalog`] is the never-pulled placeholder: filling
/// it in requires looking at the filesystem, which is the host's job.
pub fn store_apps(config: &FastforgeConfig) -> Vec<StoreApp> {
    let mut apps = Vec::new();

    if let Some(appstore) = config.stores.appstore.as_ref() {
        for app in &appstore.apps {
            // An entry without an identifier cannot be addressed by a URL and
            // cannot be synced; fastforge reports it as a failed catalog
            // target. Studio surfaces the same problem through the store's
            // app count differing from the list length.
            let Some(identifier) = app.identifier() else {
                continue;
            };
            apps.push(StoreApp {
                id: store_app_id(StoreKind::AppStore, identifier),
                store: StoreKind::AppStore,
                identifier: identifier.to_owned(),
                name: app.name.clone(),
                app_id: app.app_id.clone(),
                sku: app.sku.clone(),
                track: None,
                platform: StoreKind::AppStore.platform(),
                catalog: CatalogState::empty(StoreKind::AppStore, identifier),
            });
        }
    }

    if let Some(googleplay) = config.stores.googleplay.as_ref() {
        for app in &googleplay.apps {
            let Some(identifier) = app.identifier() else {
                continue;
            };
            apps.push(StoreApp {
                id: store_app_id(StoreKind::GooglePlay, identifier),
                store: StoreKind::GooglePlay,
                identifier: identifier.to_owned(),
                name: None,
                app_id: None,
                sku: None,
                track: app.track.clone(),
                platform: StoreKind::GooglePlay.platform(),
                catalog: CatalogState::empty(StoreKind::GooglePlay, identifier),
            });
        }
    }

    apps
}

/// Required fields per authentication method, so the UI can say which field to
/// fix rather than just "not configured".
fn evaluate_appstore_auth(
    auth: &AppStoreAuthConfig,
    env: &dyn EnvLookup,
) -> (AuthType, AuthStatus) {
    let api_key = [
        (
            "key_id",
            defaults::APPSTORE_KEY_ID,
            resolve_field(auth.key_id.as_deref(), defaults::APPSTORE_KEY_ID, env),
        ),
        (
            "issuer_id",
            defaults::APPSTORE_ISSUER_ID,
            resolve_field(auth.issuer_id.as_deref(), defaults::APPSTORE_ISSUER_ID, env),
        ),
        (
            "key_path",
            defaults::APPSTORE_KEY_PATH,
            resolve_field(auth.key_path.as_deref(), defaults::APPSTORE_KEY_PATH, env),
        ),
    ];
    let username_password = [
        (
            "username",
            defaults::APPSTORE_USERNAME,
            resolve_field(auth.username.as_deref(), defaults::APPSTORE_USERNAME, env),
        ),
        (
            "password",
            defaults::APPSTORE_PASSWORD,
            resolve_field(auth.password.as_deref(), defaults::APPSTORE_PASSWORD, env),
        ),
    ];

    // Same precedence as fastforge's `auth_type()`: any API-key signal wins,
    // because store API commands only support API keys.
    if api_key
        .iter()
        .any(|(_, _, source)| *source != FieldSource::Unset)
    {
        (AuthType::ApiKey, status_for(&api_key))
    } else if username_password
        .iter()
        .any(|(_, _, source)| *source != FieldSource::Unset)
    {
        (AuthType::UsernamePassword, status_for(&username_password))
    } else {
        // Nothing at all: report the API-key fields, since that is the path
        // `fastforge appstore` documents.
        (AuthType::Unknown, status_for(&api_key))
    }
}

fn evaluate_googleplay_auth(
    auth: &GooglePlayAuthConfig,
    env: &dyn EnvLookup,
) -> (AuthType, AuthStatus) {
    let key = resolve_field(
        auth.service_account_key.as_deref(),
        defaults::GOOGLEPLAY_SERVICE_ACCOUNT_KEY,
        env,
    );
    let json = resolve_field(
        auth.service_account_json.as_deref(),
        defaults::GOOGLEPLAY_SERVICE_ACCOUNT_JSON,
        env,
    );

    // Either form satisfies Google Play, so this is an "any of" check rather
    // than the "all of" the App Store needs.
    let satisfied = [
        (
            "service_account_key",
            defaults::GOOGLEPLAY_SERVICE_ACCOUNT_KEY,
            key,
        ),
        (
            "service_account_json",
            defaults::GOOGLEPLAY_SERVICE_ACCOUNT_JSON,
            json,
        ),
    ];

    let ready: Vec<AuthFieldSource> = satisfied
        .iter()
        .filter_map(|(field, _, source)| field_source(field, source))
        .collect();

    if ready.is_empty() {
        let missing = satisfied
            .iter()
            .map(|(field, keys, _)| AuthFieldSource::unset(field, keys))
            .collect();
        (AuthType::Unknown, AuthStatus::Incomplete { missing })
    } else {
        (
            AuthType::ServiceAccount,
            AuthStatus::Ready { sources: ready },
        )
    }
}

/// Every listed field must resolve.
fn status_for(fields: &[(&str, &[&str], FieldSource)]) -> AuthStatus {
    let missing: Vec<AuthFieldSource> = fields
        .iter()
        .filter(|(_, _, source)| *source == FieldSource::Unset)
        .map(|(field, keys, _)| AuthFieldSource::unset(field, keys))
        .collect();

    if missing.is_empty() {
        AuthStatus::Ready {
            sources: fields
                .iter()
                .filter_map(|(field, _, source)| field_source(field, source))
                .collect(),
        }
    } else {
        AuthStatus::Incomplete { missing }
    }
}

fn field_source(field: &str, source: &FieldSource) -> Option<AuthFieldSource> {
    match source {
        FieldSource::Config => Some(AuthFieldSource::from_config(field)),
        FieldSource::Env(key) => Some(AuthFieldSource::from_env(field, key)),
        FieldSource::Unset => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::config::MapEnv;

    fn config(yaml: &str) -> FastforgeConfig {
        FastforgeConfig::parse(yaml).unwrap()
    }

    #[test]
    fn an_unconfigured_project_still_lists_both_stores() {
        let connections = store_connections(&FastforgeConfig::default(), &MapEnv::default());
        assert_eq!(connections.len(), 2);
        assert!(connections.iter().all(|c| !c.configured));
        assert!(
            connections
                .iter()
                .all(|c| c.auth_status == AuthStatus::NotConfigured)
        );
        assert_eq!(connections[0].name, "App Store Connect");
    }

    #[test]
    fn complete_api_key_config_is_ready() {
        let config = config(
            r#"
stores:
  appstore:
    auth:
      key_id: ABC
      issuer_id: DEF
      key_path: ./AuthKey.p8
    apps:
      - bundle_id: com.example.myapp
"#,
        );
        let connection = store_connection(&config, StoreKind::AppStore, &MapEnv::default());
        assert!(connection.configured);
        assert_eq!(connection.auth_type, AuthType::ApiKey);
        assert_eq!(connection.app_count, 1);
        let AuthStatus::Ready { sources } = connection.auth_status else {
            panic!("expected ready, got {:?}", connection.auth_status);
        };
        assert_eq!(sources.len(), 3);
        assert!(sources.iter().all(|source| source.source == "config"));
    }

    #[test]
    fn credentials_from_the_environment_are_reported_by_variable_name() {
        let config = config("stores:\n  appstore:\n    apps: []\n");
        let env = MapEnv::new([
            ("APP_STORE_CONNECT_KEY_ID", "ABC"),
            ("APP_STORE_CONNECT_ISSUER_ID", "DEF"),
            ("APP_STORE_CONNECT_KEY_PATH", "/tmp/AuthKey.p8"),
        ]);
        let connection = store_connection(&config, StoreKind::AppStore, &env);
        let AuthStatus::Ready { sources } = connection.auth_status else {
            panic!("expected ready");
        };
        assert_eq!(sources[0].source, "env:APP_STORE_CONNECT_KEY_ID");
        // The value itself never reaches the wire.
        let json = serde_json::to_string(&sources).unwrap();
        assert!(!json.contains("ABC"), "credential values must not leak");
    }

    #[test]
    fn a_partial_api_key_reports_exactly_what_is_missing() {
        let config = config(
            r#"
stores:
  appstore:
    auth:
      key_id: ABC
    apps: []
"#,
        );
        let connection = store_connection(&config, StoreKind::AppStore, &MapEnv::default());
        assert_eq!(connection.auth_type, AuthType::ApiKey);
        let AuthStatus::Incomplete { missing } = connection.auth_status else {
            panic!("expected incomplete");
        };
        let fields: Vec<&str> = missing.iter().map(|f| f.field.as_str()).collect();
        assert_eq!(fields, ["issuer_id", "key_path"]);
        assert_eq!(
            missing[0].candidates,
            ["APP_STORE_CONNECT_ISSUER_ID", "APPSTORE_APIISSUER"]
        );
    }

    #[test]
    fn an_unresolved_env_ref_counts_as_missing() {
        let config = config(
            r#"
stores:
  appstore:
    auth:
      key_id: ${NOT_SET_ANYWHERE}
      issuer_id: DEF
      key_path: ./AuthKey.p8
    apps: []
"#,
        );
        let connection = store_connection(&config, StoreKind::AppStore, &MapEnv::default());
        let AuthStatus::Incomplete { missing } = connection.auth_status else {
            panic!("expected incomplete");
        };
        assert_eq!(missing.len(), 1);
        assert_eq!(missing[0].field, "key_id");
    }

    #[test]
    fn username_password_is_recognised_when_no_api_key_exists() {
        let config = config(
            r#"
stores:
  appstore:
    auth:
      username: ada@example.com
      password: hunter2
    apps: []
"#,
        );
        let connection = store_connection(&config, StoreKind::AppStore, &MapEnv::default());
        assert_eq!(connection.auth_type, AuthType::UsernamePassword);
        assert!(matches!(connection.auth_status, AuthStatus::Ready { .. }));
    }

    #[test]
    fn google_play_accepts_either_credential_form() {
        let with_key = config(
            r#"
stores:
  googleplay:
    auth:
      service_account_key: ./service-account.json
    apps: []
"#,
        );
        let connection = store_connection(&with_key, StoreKind::GooglePlay, &MapEnv::default());
        assert_eq!(connection.auth_type, AuthType::ServiceAccount);
        assert!(matches!(connection.auth_status, AuthStatus::Ready { .. }));

        let with_json = config("stores:\n  googleplay:\n    apps: []\n");
        let env = MapEnv::new([("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON", "{}")]);
        let connection = store_connection(&with_json, StoreKind::GooglePlay, &env);
        assert_eq!(connection.auth_type, AuthType::ServiceAccount);
    }

    #[test]
    fn google_play_without_credentials_lists_both_options() {
        let config = config("stores:\n  googleplay:\n    apps: []\n");
        let connection = store_connection(&config, StoreKind::GooglePlay, &MapEnv::default());
        let AuthStatus::Incomplete { missing } = connection.auth_status else {
            panic!("expected incomplete");
        };
        assert_eq!(missing.len(), 2);
    }

    #[test]
    fn apps_are_listed_in_configuration_order_across_stores() {
        let config = config(
            r#"
stores:
  appstore:
    apps:
      - bundle_id: com.example.ios
        app_id: "123"
        name: Example
      - app_id: "456"
      - name: No identifier
  googleplay:
    apps:
      - package_name: com.example.android
        track: production
"#,
        );
        let apps = store_apps(&config);
        let ids: Vec<&str> = apps.iter().map(|app| app.id.as_str()).collect();
        assert_eq!(
            ids,
            [
                "appstore:com.example.ios",
                "appstore:456",
                "googleplay:com.example.android",
            ],
            "entries without an identifier are skipped, matching fastforge's catalog targets"
        );
        assert_eq!(apps[0].name.as_deref(), Some("Example"));
        assert_eq!(
            apps[2].catalog.path,
            ".fastforge/stores/googleplay/com.example.android"
        );
        assert_eq!(apps[2].track.as_deref(), Some("production"));
        assert!(!apps[2].catalog.exists);
    }
}
