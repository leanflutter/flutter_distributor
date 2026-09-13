# Vercel

[English](../../en/publishers/vercel.md) | 简体中文

`vercel` target 把目录部署到 Vercel Production，依赖系统中的 Vercel CLI。

## 配置

```bash
export VERCEL_ORG_ID=team_or_user_id
export VERCEL_PROJECT_ID=project_id
```

请先确保 Vercel CLI 已登录，或已通过其支持的方式配置 token。

## 发布

```bash
fastforge publish --path build/web --target vercel
```

Fastforge 会在目标目录生成 `.vercel/project.json`，然后运行：

```text
vercel --prod
```

两个 ID 均为必填。也可以通过 `org-id`、`project-id` 发布参数，或 `--vercel-org-id`、`--vercel-project-id` 选项覆盖环境变量。发布结果为 CLI 输出的 `Production:` 地址。
