mod support;

use support::run_fastforge;

#[test]
fn studio_help_exposes_server_options_and_subcommands() {
    let dir = tempfile::tempdir().unwrap();
    let result = run_fastforge(dir.path(), &["studio", "--help"]);
    assert!(result.success, "{}", result.stderr);
    for option in ["serve", "doctor", "--port", "--no-open", "--web-root"] {
        assert!(result.stdout.contains(option), "{}", result.stdout);
    }
}

#[test]
fn studio_doctor_checks_the_requested_project() {
    let dir = tempfile::tempdir().unwrap();
    let result = run_fastforge(
        dir.path(),
        &["studio", "doctor", "--dir", dir.path().to_str().unwrap()],
    );
    assert!(result.success, "{}", result.stderr);
    assert!(
        result.stdout.contains("nothing to check"),
        "{}",
        result.stdout
    );
}

#[test]
fn studio_doctor_propagates_configuration_errors() {
    let dir = tempfile::tempdir().unwrap();
    std::fs::create_dir(dir.path().join(".fastforge")).unwrap();
    std::fs::write(dir.path().join(".fastforge/config.yaml"), "stores: [").unwrap();
    let result = run_fastforge(dir.path(), &["studio", "doctor"]);
    assert!(!result.success);
    assert!(result.stderr.contains("config.yaml"), "{}", result.stderr);
}
