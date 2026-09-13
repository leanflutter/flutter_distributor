//! `.fastforge/config.yaml`, as Studio reads it.
//!
//! The schema is declared here rather than borrowed from `fastforge_cli`
//! because Studio needs two things fastforge does not: it must compile to
//! `wasm32`, and it must resolve credentials *without* reading their values —
//! reporting only whether each field resolves, and from where.

mod env_ref;
mod schema;
mod stores;

pub use env_ref::{EnvLookup, MapEnv, env_ref_name};
pub use schema::{
    AppStoreApp, AppStoreAuthConfig, AppStoreConfig, FastforgeConfig, GooglePlayApp,
    GooglePlayAuthConfig, GooglePlayConfig, StoresConfig,
};
pub use stores::{store_apps, store_connection, store_connections};
