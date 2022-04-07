---
title: firebase
---

The firebase target publishes your package artifacts to the [firebase](https://console.firebase.google.com/project/_/appdistribution).

## Requirements

- `Firebase CLI`

Run the following command

```
npm install -g firebase-tools
```

## Set up environment variables

requires some environment variables set up to run correctly.

```
# Get token https://firebase.google.com/docs/cli?authuser=0#cli-ci-systems
firebase login:ci

export FIREBASE_TOKEN="your firebase login:ci Token"
```

## Usage

Run:

```
flutter_distributor publish \
  --path dist/1.0.0+1/hello_world-1.0.0+1-android.apk \
  --targets firebase \
  --firebase-app '<app ID>' \
  --firebase-testers testers@gmail.com \
  --firebase-groups flutter_distributor \
  --firebase-release-notes 'release v1.0.0' /
```

### Configure `distribute_options.yaml`

```yaml
env:
  FIREBASE_TOKEN: your token, See[https://firebase.google.com/docs/cli?authuser=0#cli-ci-systems]
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
        # Publish to firebase
        publish:
          target: firebase
          args:
            app: your app ID
            testers: testers@gmail.com
            groups: flutter_distributor
            release-notes: release v1.0.0
```

Run:

```
flutter_distributor release --name dev
```

## Related Links

- [Install the Firebase CLI](https://firebase.google.com/docs/cli?authuser=0#install_the_firebase_cli)
- [Use the CLI with CI systems](https://firebase.google.com/docs/cli?authuser=0#cli-ci-systems)
- [Use Firebase CLI - iOS](https://firebase.google.com/docs/app-distribution/ios/distribute-cli?authuser=0)
- [Use Firebase CLI - Android](https://firebase.google.com/docs/app-distribution/android/distribute-cli?authuser=0)

