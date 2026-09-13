//! Local Studio commands shared by Fastforge and the standalone Studio binary.

mod cli;
mod local;
mod server;

pub use cli::{StudioArgs, execute};
