use studio_core::config::EnvLookup;

/// The process environment, which is where fastforge itself expects store
/// credentials to come from.
///
/// Studio inherits whatever shell started `fastforge-studio serve`. That is a
/// real constraint worth knowing: credentials exported in another terminal
/// after the server started are not visible to it.
pub struct ProcessEnv;

impl EnvLookup for ProcessEnv {
    fn get(&self, key: &str) -> Option<String> {
        std::env::var(key).ok()
    }
}
