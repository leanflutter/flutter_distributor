use super::envelope::ApiError;

/// Longest name a project may carry. Generous, but bounded so a stray paste
/// cannot grow the registry file without limit.
const MAX_NAME_LEN: usize = 200;

/// Trims and bounds a project name.
pub fn validate_project_name(name: &str) -> Result<String, ApiError> {
    let name = name.trim();
    if name.is_empty() {
        return Err(ApiError::bad_request(
            "INVALID_REQUEST",
            "`name` must not be empty",
        ));
    }
    if name.chars().count() > MAX_NAME_LEN {
        return Err(ApiError::bad_request(
            "INVALID_REQUEST",
            format!("`name` must be at most {MAX_NAME_LEN} characters"),
        ));
    }
    if name.contains(['\n', '\r', '\0']) {
        return Err(ApiError::bad_request(
            "INVALID_REQUEST",
            "`name` must be a single line",
        ));
    }
    Ok(name.to_owned())
}

/// Checks a store app identifier — a bundle id or an Android package name.
///
/// Both are reverse-DNS labels, and the identifier also becomes a directory
/// name under `.fastforge/stores/`, so anything that is not a dotted label is
/// rejected here rather than turning into a path problem later. Numeric App
/// Store ids are allowed too, because fastforge falls back to `app_id` when a
/// bundle id is absent.
pub fn validate_identifier(identifier: &str) -> Result<String, ApiError> {
    let identifier = identifier.trim();
    if identifier.is_empty() {
        return Err(ApiError::bad_request(
            "INVALID_REQUEST",
            "`identifier` must not be empty",
        ));
    }

    let numeric = identifier.chars().all(|c| c.is_ascii_digit());
    let dotted_label = identifier.split('.').all(|segment| {
        !segment.is_empty()
            && segment
                .chars()
                .all(|c| c.is_ascii_alphanumeric() || c == '_' || c == '-')
    });

    if !numeric && !dotted_label {
        return Err(ApiError::bad_request(
            "INVALID_IDENTIFIER",
            format!("`{identifier}` is not a valid bundle id or package name"),
        ));
    }

    Ok(identifier.to_owned())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn names_are_trimmed() {
        assert_eq!(
            validate_project_name("  Mobile App  ").unwrap(),
            "Mobile App"
        );
    }

    #[test]
    fn empty_and_multiline_names_are_rejected() {
        assert!(validate_project_name("   ").is_err());
        assert!(validate_project_name("one\ntwo").is_err());
        assert!(validate_project_name(&"x".repeat(MAX_NAME_LEN + 1)).is_err());
    }

    #[test]
    fn real_identifiers_pass() {
        for identifier in [
            "com.example.myapp",
            "com.example.my_app",
            "com.example.my-app",
            "1234567890",
        ] {
            assert!(
                validate_identifier(identifier).is_ok(),
                "{identifier} should be accepted"
            );
        }
    }

    #[test]
    fn path_shaped_identifiers_are_rejected_before_they_reach_the_filesystem() {
        for identifier in [
            "",
            "..",
            "com..example",
            "com.example/../etc",
            "com example",
            "com.example.app\0",
        ] {
            assert!(
                validate_identifier(identifier).is_err(),
                "{identifier:?} should be rejected"
            );
        }
    }
}
