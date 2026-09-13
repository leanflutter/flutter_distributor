# `.fastforge/config.yaml`

Registers App Store, AppGallery, and Google Play apps for the aggregated
`fastforge store` commands (`store list`, `store catalog pull|push`) and for
Studio (`fastforge studio doctor` checks these credentials). Loaded from the
current directory; a missing file is treated as empty.

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
        platform: IOS          # IOS (default) | MAC_OS | TV_OS | VISION_OS

  appgallery:
    auth:
      service_account_key: "${APP_GALLERY_SERVICE_ACCOUNT_KEY}"
    apps:
      - app_id: "987654321"
        package_name: com.example.myapp

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
| `apps[].platform` | `IOS` (default), `MAC_OS`, `TV_OS`, `VISION_OS`; passed to catalog pull |

App Store app entries reject unknown keys, so a typo such as `platfrom:` fails
parsing instead of silently falling back to iOS.

## AppGallery fields

| Field | Description |
| --- | --- |
| `auth.service_account_key` / `auth.service_account_json` | Service-account JSON file path / inline content |
| `auth.client_id` / `auth.client_secret` | Legacy API client credentials |
| `apps[].app_id` | AppGallery app ID (preferred identifier) |
| `apps[].package_name` | Android package name (fallback identifier) |
| `apps[].name` | Optional display name |

`store list` shows AppGallery apps; `store catalog pull|push` covers only App
Store and Google Play.

## Google Play fields

| Field | Description |
| --- | --- |
| `auth.service_account_key` | Path to the service-account JSON file |
| `auth.service_account_json` | Service-account JSON content inline |
| `apps[].package_name` | Google Play package name |
| `apps[].track` | Optional default track (parsed, but not currently consumed by any command) |

## Environment variables and security

- An `auth` value that is exactly `${ENV_NAME}` is replaced by that variable
  (no partial interpolation; an unset variable stays as the literal text).
  Empty `auth` fields fall back to default variables:

  | Field | Environment variables (first set wins) |
  | --- | --- |
  | appstore `key_id` | `APP_STORE_CONNECT_KEY_ID`, `APPSTORE_APIKEY` |
  | appstore `issuer_id` | `APP_STORE_CONNECT_ISSUER_ID`, `APPSTORE_APIISSUER` |
  | appstore `key_path` | `APP_STORE_CONNECT_KEY_PATH` |
  | appstore `username` / `password` | `APPSTORE_USERNAME` / `APPSTORE_PASSWORD` |
  | googleplay `service_account_key` | `GOOGLE_PLAY_SERVICE_ACCOUNT_KEY`, `GOOGLE_APPLICATION_CREDENTIALS` |
  | googleplay `service_account_json` | `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` |
  | appgallery `service_account_key` / `_json` | `APP_GALLERY_SERVICE_ACCOUNT_KEY` / `APP_GALLERY_SERVICE_ACCOUNT_JSON` |
  | appgallery `client_id` / `client_secret` | `APP_GALLERY_CLIENT_ID` / `APP_GALLERY_CLIENT_SECRET` |
 The store API and catalog executors still
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
