---
title: firebase-hosting
---

The firebase-hosting target publishes your web artifacts to the [firebase hosting](https://firebase.google.com/docs/hosting).

## Get publishing arguments

Open [https://firebase.google.com](https://firebase.google.com/) And log in

### Get `project-id`

Select the project you want to deploy, Open the Project Settings page and find `Project ID`.

## Usage

Run:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-web \
  --targets firebase-hosting \
  --firebase-hosting-project-id your-project-id
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
          target: firebase-hosting
          args:
            project-id: your-project-id
```

Run:

```
flutter_distributor release --name dev
```
