//! Domain model, wire contract and pure logic shared by every Fastforge Studio
//! host.
//!
//! This crate performs no I/O: it holds the types the HTTP contract is written
//! in, the rules that decide what a valid transition is, and the parsers that
//! turn `.fastforge/` configuration into those types. Hosts
//! (`studio_cli`, `studio_api`) own their own storage and
//! their own async runtime, which is what lets the same logic serve both a
//! `tokio` server and a `wasm32` Cloudflare Worker.

pub mod api;
pub mod config;
pub mod model;
pub mod openapi;
pub mod policy;

pub use api::{
    ApiError, Capabilities, StudioMode, capabilities_for, error_envelope, success_envelope,
};
pub use model::{
    CatalogEntry, CatalogEntryKind, CatalogState, CatalogTree, Platform, Project, Run, RunEvent,
    RunKind, RunStatus, StoreApp, StoreConnection, StoreKind,
};
