# Custom Builder

English | [简体中文](../../zh-Hans/builders/custom.md)

Custom Builder runs any command and collects artifacts with glob rules. The module is implemented, but it is not yet connected to `fastforge build`, `fastforge package`, or a built-in workflow action.

## Builder Model

A custom build requires the following information:

| Parameter           | Required | Description                                             |
| ------------------- | :------: | ------------------------------------------------------- |
| `command`           |   Yes    | Program or script to run                                |
| `args`              |    No    | A string or an array of strings                         |
| `output-directory`  |   Yes    | Artifact root directory                                 |
| `artifact-patterns` |   Yes    | Glob string or array relative to the artifact directory |

The build fails if the command returns a nonzero exit status or if it succeeds without matching any artifacts.

## Current Recommendation

Until the top-level CLI integration is complete, run custom builds as ordinary shell steps in a local workflow, then pass the artifact path to `fastforge publish`. Do not try to use a nonexistent `--platform custom` option.

Custom Builder is different from the `custom` package format. `fastforge package --targets custom` still builds with Flutter Builder (or Xcode Builder for native macOS) and then runs your packaging script; see [Packaging](../packaging.md#custom-format).
