use thiserror::Error;

use crate::model::RunStatus;

/// The run state machine, and the only place it is written down.
///
/// ```text
/// queued ──▶ running ──┬──▶ succeeded
///   │          │       ├──▶ failed
///   │          │       └──▶ cancelled
///   └──────────┴──▶ cancelled
/// ```
///
/// Local runs skip `queued`; hosted runs do not. Both use this table, so a run
/// cannot mean different things depending on which host produced it.
#[derive(Debug, Error, PartialEq, Eq)]
pub enum RunStateError {
    #[error("a {0} run has already finished and cannot become {1}")]
    AlreadyTerminal(&'static str, &'static str),
    #[error("a run cannot move from {0} to {1}")]
    Illegal(&'static str, &'static str),
}

pub fn transition(current: RunStatus, next: RunStatus) -> Result<RunStatus, RunStateError> {
    if current.is_terminal() {
        return Err(RunStateError::AlreadyTerminal(
            current.as_str(),
            next.as_str(),
        ));
    }

    let allowed = matches!(
        (current, next),
        (RunStatus::Queued, RunStatus::Running)
            | (RunStatus::Queued | RunStatus::Running, RunStatus::Cancelled)
            | (RunStatus::Running, RunStatus::Succeeded | RunStatus::Failed)
    );

    if allowed {
        Ok(next)
    } else {
        Err(RunStateError::Illegal(current.as_str(), next.as_str()))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn happy_path_queued_to_succeeded() {
        let status = transition(RunStatus::Queued, RunStatus::Running).unwrap();
        assert_eq!(
            transition(status, RunStatus::Succeeded).unwrap(),
            RunStatus::Succeeded
        );
    }

    #[test]
    fn cancellation_is_allowed_from_both_live_states() {
        assert!(transition(RunStatus::Queued, RunStatus::Cancelled).is_ok());
        assert!(transition(RunStatus::Running, RunStatus::Cancelled).is_ok());
    }

    #[test]
    fn a_finished_run_never_moves_again() {
        assert_eq!(
            transition(RunStatus::Succeeded, RunStatus::Running),
            Err(RunStateError::AlreadyTerminal("succeeded", "running"))
        );
        assert_eq!(
            transition(RunStatus::Cancelled, RunStatus::Failed),
            Err(RunStateError::AlreadyTerminal("cancelled", "failed"))
        );
    }

    #[test]
    fn queued_cannot_skip_straight_to_a_result() {
        assert_eq!(
            transition(RunStatus::Queued, RunStatus::Succeeded),
            Err(RunStateError::Illegal("queued", "succeeded"))
        );
    }

    #[test]
    fn running_cannot_go_back_to_queued() {
        assert_eq!(
            transition(RunStatus::Running, RunStatus::Queued),
            Err(RunStateError::Illegal("running", "queued"))
        );
    }
}
