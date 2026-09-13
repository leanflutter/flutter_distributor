use std::collections::HashMap;

/// Expands a leading `~/` (from `HOME` / `USERPROFILE`) and `$VAR` / `${VAR}`
/// references using `environment`. Unknown variables expand to an empty
/// string. Mirrors Dart's `shell_executor` `pathExpansion`.
pub fn path_expansion(path: &str, environment: &HashMap<String, String>) -> String {
    let mut path = path.to_string();
    if let Some(rest) = path.strip_prefix("~/") {
        let home = environment
            .get("HOME")
            .or_else(|| environment.get("USERPROFILE"))
            .cloned()
            .unwrap_or_default();
        path = format!("{home}/{rest}");
    }

    let is_word = |c: char| c.is_ascii_alphanumeric() || c == '_';
    let mut output = String::with_capacity(path.len());
    let mut rest = path.as_str();
    while let Some(index) = rest.find('$') {
        output.push_str(&rest[..index]);
        let after = &rest[index + 1..];
        if let Some(braced) = after.strip_prefix('{')
            && let Some(end) = braced.find('}')
            && end > 0
            && braced[..end].chars().all(is_word)
        {
            let name = &braced[..end];
            output.push_str(environment.get(name).map(String::as_str).unwrap_or(""));
            rest = &braced[end + 1..];
            continue;
        }
        let len = after.find(|c: char| !is_word(c)).unwrap_or(after.len());
        if len > 0 {
            let name = &after[..len];
            output.push_str(environment.get(name).map(String::as_str).unwrap_or(""));
            rest = &after[len..];
        } else {
            output.push('$');
            rest = after;
        }
    }
    output.push_str(rest);
    output
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn expands_home_and_variables() {
        let env = HashMap::from([
            ("HOME".to_string(), "/home/me".to_string()),
            ("FVM".to_string(), "fvm".to_string()),
            ("VER".to_string(), "3.24.0".to_string()),
        ]);
        assert_eq!(
            path_expansion("~/$FVM/versions/${VER}", &env),
            "/home/me/fvm/versions/3.24.0"
        );
        assert_eq!(path_expansion("/opt/$MISSING/x", &env), "/opt//x");
        assert_eq!(path_expansion("/opt/$/x", &env), "/opt/$/x");
        assert_eq!(path_expansion("/plain/path", &env), "/plain/path");
    }

    #[test]
    fn falls_back_to_userprofile() {
        let env = HashMap::from([("USERPROFILE".to_string(), "C:\\Users\\me".to_string())]);
        assert_eq!(path_expansion("~/flutter", &env), "C:\\Users\\me/flutter");
    }
}
