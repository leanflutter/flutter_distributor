use serde::{Deserialize, Serialize};

/// What a run is doing.
///
/// Only catalog synchronisation exists this round. Workflow execution becomes
/// another variant later rather than a second, parallel concept — which is why
/// runs are modelled now even though there is no runs page yet.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum RunKind {
    #[serde(rename = "store.catalog.pull")]
    StoreCatalogPull,
    #[serde(rename = "store.catalog.push")]
    StoreCatalogPush,
}

impl RunKind {
    pub fn as_str(self) -> &'static str {
        match self {
            RunKind::StoreCatalogPull => "store.catalog.pull",
            RunKind::StoreCatalogPush => "store.catalog.push",
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum RunStatus {
    /// Only the hosted service queues. Locally a run starts immediately.
    Queued,
    Running,
    Succeeded,
    Failed,
    Cancelled,
}

impl RunStatus {
    pub fn as_str(self) -> &'static str {
        match self {
            RunStatus::Queued => "queued",
            RunStatus::Running => "running",
            RunStatus::Succeeded => "succeeded",
            RunStatus::Failed => "failed",
            RunStatus::Cancelled => "cancelled",
        }
    }

    pub fn is_terminal(self) -> bool {
        matches!(
            self,
            RunStatus::Succeeded | RunStatus::Failed | RunStatus::Cancelled
        )
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Run {
    pub id: String,
    pub kind: RunKind,
    pub project_id: String,
    /// What the run acts on — a store app id for catalog runs.
    pub target_id: String,
    pub status: RunStatus,
    /// Push only. A dry run reports what it would change and writes nothing.
    #[serde(default)]
    pub dry_run: bool,
    pub created_at: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub started_at: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub finished_at: Option<String>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub error: Option<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum LogLevel {
    Debug,
    Info,
    Warn,
    Error,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Progress {
    pub current: u32,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub total: Option<u32>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub label: Option<String>,
}

/// One frame of a run's event stream.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RunEvent {
    /// Monotonic per run. Sent as the SSE event id so a reconnecting client can
    /// resume with `Last-Event-ID` instead of replaying from the start.
    pub seq: u64,
    pub at: String,
    pub level: LogLevel,
    pub message: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub progress: Option<Progress>,
    /// Present on the final frame so a client that only reads the stream still
    /// learns how the run ended.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub status: Option<RunStatus>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn run_kind_uses_dotted_wire_names() {
        assert_eq!(
            serde_json::to_value(RunKind::StoreCatalogPull).unwrap(),
            serde_json::json!("store.catalog.pull")
        );
    }

    #[test]
    fn terminal_statuses_are_the_three_endings() {
        assert!(!RunStatus::Queued.is_terminal());
        assert!(!RunStatus::Running.is_terminal());
        assert!(RunStatus::Succeeded.is_terminal());
        assert!(RunStatus::Failed.is_terminal());
        assert!(RunStatus::Cancelled.is_terminal());
    }
}
