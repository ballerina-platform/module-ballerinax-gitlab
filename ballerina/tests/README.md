# Running Tests

## Prerequisites

To run the tests against a live GitLab instance you need a personal access token with the `api` scope, a project on which you have the Owner role (deleting issues requires it), a group you belong to, and the numeric ID of a namespace in which you can both create and delete projects. For a group namespace, that means the Owner role on the group. Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-gitlab/blob/main/ballerina/README.md#setup-guide) to create the token.

The live tests create and delete issues, labels, branches and a project. Run them against a sandbox project, never a production one. The project needs a `main` branch containing a `README.md` file.

## Test environments

There are two test environments. The default is a mock server for the GitLab REST API. The other is a live GitLab instance.

 Test Groups | Environment
-------------|------------------------------------------------
 mock_tests  | Mock server for the GitLab REST API (default)
 live_tests  | GitLab REST API

Creating and merging merge requests, creating pipelines and creating releases run against the mock only, because they need repository state (a diverging branch, a CI configuration, a new tag) that a test cannot set up on its own.

## Running tests against the mock server

No configuration is needed. When `IS_LIVE_SERVER` is not set to `true`, the tests run against the mock server on port `9090`.

```bash
./gradlew clean test
```

## Running tests against a live GitLab instance

Set the following environment variables, then run the tests.

| Variable | Description |
|---|---|
| `IS_LIVE_SERVER` | Set to `true` to target `GITLAB_URL` instead of the mock server |
| `GITLAB_URL` | REST API base URL, e.g. `https://gitlab.com/api/v4` |
| `GITLAB_TOKEN` | Personal access token with the `api` scope |
| `GITLAB_PROJECT_ID` | Numeric ID of the sandbox project |
| `GITLAB_GROUP_ID` | Numeric ID of a group you belong to |
| `GITLAB_NAMESPACE_ID` | Numeric ID of the namespace in which test projects are created |

```bash
export IS_LIVE_SERVER=true
export GITLAB_URL="https://gitlab.com/api/v4"
export GITLAB_TOKEN="<personal access token>"
export GITLAB_PROJECT_ID="<project id>"
export GITLAB_GROUP_ID="<group id>"
export GITLAB_NAMESPACE_ID="<namespace id>"
./gradlew clean test -Pgroups=live_tests
```
