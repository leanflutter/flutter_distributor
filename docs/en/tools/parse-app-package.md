# Parse App Package

## Installation

```
dart pub global activate parse_app_package
```

## Usage

```
parse_app_package hello_world-1.0.0+1-android.apk
```

Output:

```
{
  "platform": "android",
  "identifier": "com.example.hello_world",
  "name": "hello_world",
  "version": "1.0.0",
  "buildNumber": 1
}
```
