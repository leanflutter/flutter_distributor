# `.fastforge/config.yaml`

Registers App Store and Google Play apps for the aggregated `fastforge store`
commands (`store list`, `store catalog pull|push`).

```yaml
stores:
  appstore:
    auth:
      key_id: "${APP_STORE_CONNECT_KEY_ID}"
      issuer_id: "${APP_STORE_CONNECT_ISSUER_ID}"
      key_path: "${APP_STORE_CONNECT_KEY_PATH}"
    apps:
      - bundle_id: com.example.myapp
        app_id: "1234567890"
        sku: MYAPP
        name: My App

  googleplay:
    auth:
      service_account_key: "${GOOGLE_PLAY_SERVICE_ACCOUNT_KEY}"
    apps:
      - package_name: com.example.myapp
        track: production
```

## App Store fields

| Field | Description |
| --- | --- |
| `auth.key_id` | App Store Connect API Key ID |
| `auth.issuer_id` | Issuer ID |
| `auth.key_path` | Path to the `.p8` private key |
| `auth.username` / `auth.password` | Alternative username + app-specific-password auth |
| `apps[].bundle_id` | Preferred application identifier |
| `apps[].app_id` | Fallback identifier for catalog commands when the bundle ID is missing |
| `apps[].sku` / `apps[].name` | Optional metadata |

## Google Play fields

| Field | Description |
| --- | --- |
| `auth.service_account_key` | Path to the service-account JSON file |
| `auth.service_account_json` | Service-account JSON content inline |
| `apps[].package_name` | Google Play package name |
| `apps[].track` | Optional default track |

## Environment variables and security

- `auth` fields support full `${ENV_NAME}` references and also fall back to
  the default environment variables. The store API and catalog executors still
  establish authentication **from process environment variables**, so export
  credentials before running commands even when they appear in the file.
- Store real credentials in CI secrets or local environment variables. Never
  commit `.p8` files, service-account JSON, or passwords.
- A config containing only app identifiers is safe to commit; add the file to
  `.gitignore` if it embeds real secrets.

# Other `.fastforge/` contents

- `workflows/` — local workflow YAML (see `workflow.md` in this directory).
- `stores/` — default output directory for catalog pull:
  `stores/appstore/<bundle-id>/`, `stores/googleplay/<package-name>/`.
