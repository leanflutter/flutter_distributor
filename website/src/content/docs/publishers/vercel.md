---
title: vercel
---

The vercel target publishes your web artifacts to the [vercel.com](https://vercel.com).

## Get publishing arguments

Open [vercel.com](https://vercel.com) And log in

### Get `org-id`

Open the Account Settings page and find `Your ID`.

### Get `project-id`

Select the project you want to deploy, Open the Project Settings page and find `Project ID`.

## Usage

Run:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-web \
  --targets vercel \
  --vercel-org-id your-org-id \
  --vercel-project-id your-project-id
```

### Configure `distribute_options.yaml`

```yaml
output: dist/
releases:
  - name: dev
    jobs:
      - name: web-direct
        package:
          platform: web
          target: direct
        publish:
          target: vercel
          args:
            org-id: your-org-id
            project-id: your-project-id
```

Run:

```
flutter_distributor release --name dev
```
