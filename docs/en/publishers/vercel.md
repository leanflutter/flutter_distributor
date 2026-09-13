# Vercel

English | [简体中文](../../zh-Hans/publishers/vercel.md)

The `vercel` target deploys a directory to Vercel Production and depends on the Vercel CLI installed on the system.

## Configuration

```bash
export VERCEL_ORG_ID=team_or_user_id
export VERCEL_PROJECT_ID=project_id
```

Make sure the Vercel CLI is signed in, or configure a token through one of its supported methods.

## Publish

```bash
fastforge publish --path build/web --target vercel
```

Fastforge generates `.vercel/project.json` in the target directory, then runs:

```text
vercel --prod
```

Both IDs are required. You can override the environment variables with the `org-id` and `project-id` publishing arguments, or the `--vercel-org-id` and `--vercel-project-id` options. The publishing result is the `Production:` URL printed by the CLI.
