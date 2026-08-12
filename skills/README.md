# Fastforge Skills

Agent skills for the [Fastforge CLI](https://github.com/fastforgedev/fastforge) — they teach Claude (Claude Code, Cowork, or any Agent-Skills-compatible harness) how to build, package, publish, and operate app stores with `fastforge`, including the sharp edges that are easy to get wrong without reading the docs.

## Skills

| Skill | Covers | Typical requests |
| --- | --- | --- |
| [`fastforge`](fastforge/) | Installation, `.fastforge/config.yaml`, workflow file syntax and troubleshooting, `fastforge analyze` reports, general usage; fallback router to the skills below | "install fastforge", "my workflow won't validate", "analyze this apk", "why does `fastforge upgrade` do nothing" |
| [`fastforge-package`](fastforge-package/) | `fastforge build` / `fastforge package` / the `fastforge/package` action; builder routing (Gradle / Xcode / Flutter), flavors, hooks, artifact locations, the platform support matrix | "package my app as a dmg", "build an apk with the dev flavor" |
| [`fastforge-publish`](fastforge-publish/) | `fastforge publish` and every publisher target (S3/MinIO/Qiniu/OSS/COS, fir.im, Firebase, GitHub Releases, App Store upload, AppGallery, Vercel, custom); end-to-end package-then-publish release workflows | "upload this zip to GitHub Releases", "send the apk to testers", "set up a release pipeline" |
| [`fastforge-stores`](fastforge-stores/) | `fastforge appstore` / `googleplay` / `store`: build uploads, TestFlight processing, versions, review submissions, Play edits and tracks, catalog (listings/screenshots) sync | "submit for review", "push the aab to the internal track", "pull our store screenshots" |

## Organization

- **`fastforge` is the base.** It owns the knowledge every scenario shares — configuration, workflow YAML syntax, artifact analysis — and catches requests that don't clearly belong to a scenario skill. Its `references/` are cross-referenced by the other skills (e.g. `../fastforge/references/workflow.md`), so the four directories must be installed **side by side** under the same parent.
- **Workflows are a mechanism, not a skill.** `fastforge-package` and `fastforge-publish` decide internally whether a request is a one-off CLI call or should be captured as a `.fastforge/workflows/*.yml` file; the syntax lives once in the base skill.
- **`publish` vs `stores` boundary:** publishing moves one artifact to a service and stops there; versions, review, tracks, and metadata are store operations. Both skills state this to avoid mistriggering.

## Layout

```text
skills/
├── fastforge/
│   ├── SKILL.md
│   └── references/{config,workflow,analyze}.md
├── fastforge-package/
│   ├── SKILL.md
│   └── references/{android,ios,macos}.md
├── fastforge-publish/
│   ├── SKILL.md
│   └── references/publishers.md
└── fastforge-stores/
    ├── SKILL.md
    └── references/{appstore,googleplay,catalog}.md
```

## Installing

Install with the [`skills`](https://skills.sh) CLI. Install all four together — they reference each other by relative path and must stay siblings:

```bash
npx skills add fastforgedev/skills
```

Add `-g` to install globally (for every project) instead of into the current project:

```bash
npx skills add fastforgedev/skills -g
```

To remove:

```bash
npx skills remove fastforge fastforge-package fastforge-publish fastforge-stores
```

After installing, start a new session and ask something a skill should catch — e.g. "package this Flutter project as a dmg" or "upload dist/app.aab to the internal track" — the matching skill triggers on its own.

## Scope and source of truth

Content is distilled from the Fastforge CLI documentation ([`fastforge/docs/en`](../fastforge/docs/en/)) and the CLI implementation as of 0.7.x (August 2026), including the full platform/format packaging matrix, optional `--platform` inference, and the `playstore`/`pgyer` publish targets. When the CLI and these skills disagree, trust `fastforge <command> --help` and update the skill.
