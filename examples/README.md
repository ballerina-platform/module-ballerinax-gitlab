# Examples

The `ballerinax/gitlab` connector provides practical examples illustrating usage in various scenarios.

1. [Unassigned issue triage](./unassigned_issue_triage/unassigned_issue_triage.md) - Find every open issue with no assignee and mark it for triage with a label, creating the label if the project does not have it.
2. [Release notes from merged merge requests](./merged_release_notes/merged_release_notes.md) - Collect the merge requests merged into the default branch since the last release, draft notes crediting authors and reviewers, and publish the release.

## Prerequisites

1. Create a GitLab personal access token as described in the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-gitlab/blob/main/ballerina/README.md#setup-guide).

2. For each example, create a `Config.toml` file in the example's directory with the token, the project and the other values its guide lists, for example:

    ```toml
    token = "<Personal access token>"
    serviceUrl = "https://gitlab.com/api/v4"
    projectId = "<Project ID or path, e.g. 12345 or mygroup/myproject>"
    ```

Both examples are dry runs by default and change nothing until their `applyLabels` or `publish` flag is set to `true`.

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
