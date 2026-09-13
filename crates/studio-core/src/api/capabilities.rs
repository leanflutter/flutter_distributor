use serde::{Deserialize, Serialize};

/// Studio runs in two shapes against the same UI.
///
/// - `local` — a companion to the CLI on a developer machine. It reads and
///   writes `.fastforge/` directly.
/// - `cloud` — the hosted service.
///
/// Surfaces the current mode cannot serve are hidden rather than disabled, so
/// navigation never contains a dead link.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum StudioMode {
    Local,
    Cloud,
}

impl StudioMode {
    pub fn as_str(self) -> &'static str {
        match self {
            StudioMode::Local => "local",
            StudioMode::Cloud => "cloud",
        }
    }
}

/// What this deployment can actually do.
///
/// Mirrors the `Capabilities` type in `apps/studio-web/src/lib/capabilities.tsx`, and
/// replaces the build-time `VITE_STUDIO_MODE` guess it used to make.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Capabilities {
    pub mode: StudioMode,
    /// More than one workspace exists, so the header needs a switcher.
    pub workspaces: bool,
    /// Runs are queued before they execute, so a pending count is meaningful.
    pub run_queue: bool,
    pub members: bool,
    pub access_tokens: bool,
    pub webhooks: bool,
    pub billing: bool,
    /// The host can browse the local filesystem, so "add project" can offer a
    /// directory picker instead of asking for a pasted path.
    pub local_fs: bool,
    /// Catalog pull/push can execute here. False on the hosted service until
    /// the store clients are transport-agnostic enough to run on a Worker.
    pub catalog_sync: bool,
}

/// The capability set for a mode.
///
/// Everything workspace-shaped is off in both modes for now: workspaces are not
/// implemented, and reporting them as available would put dead entries in the
/// sidebar.
pub fn capabilities_for(mode: StudioMode) -> Capabilities {
    let local = matches!(mode, StudioMode::Local);
    Capabilities {
        mode,
        workspaces: false,
        run_queue: false,
        members: false,
        access_tokens: false,
        webhooks: false,
        billing: false,
        local_fs: local,
        catalog_sync: local,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn local_mode_offers_the_filesystem_and_catalog_sync() {
        let capabilities = capabilities_for(StudioMode::Local);
        assert!(capabilities.local_fs);
        assert!(capabilities.catalog_sync);
    }

    #[test]
    fn cloud_mode_offers_neither_yet() {
        let capabilities = capabilities_for(StudioMode::Cloud);
        assert!(!capabilities.local_fs);
        assert!(!capabilities.catalog_sync);
    }

    #[test]
    fn workspace_features_are_off_in_both_modes() {
        for mode in [StudioMode::Local, StudioMode::Cloud] {
            let capabilities = capabilities_for(mode);
            assert!(!capabilities.workspaces);
            assert!(!capabilities.members);
            assert!(!capabilities.access_tokens);
            assert!(!capabilities.webhooks);
            assert!(!capabilities.billing);
            assert!(!capabilities.run_queue);
        }
    }

    #[test]
    fn the_client_sees_camel_case_keys() {
        let value = serde_json::to_value(capabilities_for(StudioMode::Local)).unwrap();
        assert_eq!(value["mode"], serde_json::json!("local"));
        assert_eq!(value["runQueue"], serde_json::json!(false));
        assert_eq!(value["accessTokens"], serde_json::json!(false));
        assert_eq!(value["localFs"], serde_json::json!(true));
        assert_eq!(value["catalogSync"], serde_json::json!(true));
    }
}
