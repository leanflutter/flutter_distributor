---
title: github
---

The github target publishes your package artifacts to the [github](https://github.com/leanflutter/flutter\_distributor/releases) release.

## Set up environment variables

requires some environment variables set up to run correctly.

```
# Get token https://docs.github.com/cn/enterprise-server@3.2/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

export GITHUB_TOKEN="your personal access token"
```

## Usage

Run:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk \
  --targets github \
  --github-repo-owner 'leanflutter' \
  --github-repo-name 'flutter_distributor'
```

### Configure `distribute_options.yaml`

```yaml
env:
  GITHUB_TOKEN: your personal access token, See[https://docs.github.com/cn/enterprise-server@3.2/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token]
output: dist/
releases:
  - name: dev
    jobs:
      - name: release-dev-android
        package:
          platform: android
          target: apk
          build_args:
            target-platform: android-arm
        # Publish to github
        publish:
          target: github
          args:
            repo-owner: Repository owner
            repo-name: Repository name
```

Run:

```
flutter_distributor release --name dev
```

## Related Links

* [Creating a personal access token](https://docs.github.com/cn/enterprise-server@3.2/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
