# studio-api

Fastforge Studio, hosted on Cloudflare Workers. It implements the same contract
as `fastforge-studio serve`, backed by D1 instead of a checkout — see
[`openapi.yaml`](./openapi.yaml), which both hosts serve and the TypeScript
client is generated from.

## What it serves today

| Surface                              | Status                                        |
| ------------------------------------ | --------------------------------------------- |
| `GET /v1/capabilities`               | ✅ public                                      |
| `GET /openapi.json`, `GET /reference`| ✅ public                                      |
| Projects (list, create, read, rename, delete) | ✅ D1                                 |
| Stores and store apps (read)         | ✅ parsed from the project's stored config     |
| Catalog                              | ⛔ `501` — catalogs belong in R2, not wired yet |
| Catalog pull / push                  | ⛔ reported as unavailable via `capabilities`  |

Catalog sync is the one thing a Worker genuinely could do — App Store Connect
and Google Play are plain HTTP, and WebCrypto covers both signature schemes.
What blocks it is that fastforge's store clients are bound to `reqwest` and
tokio. Giving them a transport is its own piece of work, in the fastforge
repository.

## Authentication

One bearer token, held as a Worker secret, mapped to one owner. It fails
closed: without `STUDIO_API_TOKEN` configured the API answers `500`, because
"auth is not set up" must never read as "auth passed".

```bash
wrangler secret put STUDIO_API_TOKEN
```

## Development

```bash
pnpm --filter studio-api migrate:local
pnpm --filter studio-api dev
```

The crate only builds for `wasm32-unknown-unknown`, so it is excluded from the
workspace's default members — a bare `cargo build` at the repository root skips
it. Check it directly with:

```bash
cargo check -p studio-api --target wasm32-unknown-unknown
```
