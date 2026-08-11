# Fastforge Local Workflows

`fastforge workflow` discovers, validates, and runs YAML workflows under
`.fastforge/workflows/`. The syntax mirrors GitHub Actions (name / on / jobs /
steps / `${{ }}` expressions), but execution is entirely local and only the
inputs documented here are supported.

```text
your-project/
├── .fastforge/
│   └── workflows/
│       ├── android.yml
│       └── release.yml
└── project-files
```

## Minimal workflow

```yaml
name: Android package

on:
  workflow_dispatch:
    inputs:
      flavor:
        description: Build flavor
        default: production

jobs:
  package:
    name: Package Android app
    steps:
      - name: Create APK
        uses: fastforge/package
        with:
          platform: android
          target: apk
          output: dist/
          build-args: '{"flavor":"${{ inputs.flavor }}"}'
```

## CLI

```bash
fastforge workflow list [--verbose] [--dir <path>]
fastforge workflow validate .fastforge/workflows/release.yml
fastforge workflow run                             # OK when exactly one workflow exists
fastforge workflow run --file .fastforge/workflows/release.yml \
  --input flavor=staging --input channel=beta      # workflow_dispatch inputs
fastforge workflow run --file <file> --event push --workspace /path/to/project
```

- `--event` defaults to `workflow_dispatch`.
- `validate` parses structure only; it does not execute commands or actions.
- With multiple workflow files, always pass `--file` explicitly.

## `fastforge/package` action

Required: `platform`, `target`.

| Optional input | Description |
| --- | --- |
| `output` | Output directory; defaults to `dist/` |
| `artifact-name` | Artifact name template, e.g. `"my-app-{{build_name}}.{{ext}}"` |
| `skip-clean` | Skip cleaning when the string is `true` |
| `build-target` | Flutter Builder entry point (e.g. `lib/main_prod.dart`) |
| `build-args` | **JSON object string** — fields depend on the active builder |
| `hook-pre` / `hook-post` | Shell command before/after packaging |

Outputs: `artifact-count`, `artifact-paths` (comma-separated).

Which `build-args` fields exist depends on the builder the project routes to
(Gradle, Xcode, or Flutter) — the fastforge-package skill's references
document them per platform.

```yaml
- name: Package
  uses: fastforge/package
  with:
    platform: android
    target: aab
    output: artifacts/
    artifact-name: "my-app-{{build_name}}.{{ext}}"
    build-args: '{"flavor":"production","module":"app"}'
    hook-post: ./scripts/verify-artifact.sh
```

## `fastforge/publish` action

Required: `path`, `target`. Parameters go either in a `publish-args` JSON
string, or — when `publish-args` is omitted — every other `with` field except
`path`/`target` becomes a publishing parameter:

```yaml
- name: Publish
  uses: fastforge/publish
  with:
    path: dist/app.zip
    target: github
    repo: owner/repository
    release-tag: v1.0.0
```

Output: `message`.

## Execution model

The engine builds execution layers from job dependencies and reports job,
step, command, and action status as it runs. Any failure makes the overall run
fail with a nonzero exit status, so workflows compose cleanly with scripts and
CI.

## Rules that prevent the common failures

- `build-args` and `publish-args` must be valid **JSON**, not YAML objects.
  Quote the whole value: `build-args: '{"flavor":"dev"}'`.
- The package action has exactly the same platform/format coverage as the CLI
  — a format the CLI cannot package does not start working inside a workflow.
- Publishing credentials come from process environment variables; only
  non-sensitive parameters belong in `with`.
- Steps may also be plain shell commands (a step with a `run`-style command
  instead of `uses`), which is how unsupported build systems are integrated
  today: run the custom build as a shell step, then pass its artifact path to
  a `fastforge/publish` step.
