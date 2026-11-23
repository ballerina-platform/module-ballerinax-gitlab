# Unassigned issue triage

This example finds every open issue in a GitLab project that has no assignee, and marks them for triage with a label. It pages through the project's issues, skips the ones that already carry the label, creates the label if the project does not have it yet, and adds it to each issue without removing the labels the issue already has.

By default the example is a dry run: it lists the issues it would label and changes nothing. Set `applyLabels = true` to create the label and update the issues.

## Prerequisites

### 1. Set up a GitLab personal access token

Refer to the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-gitlab/blob/main/ballerina/README.md#setup-guide) to create a personal access token. The dry run needs the `read_api` scope; labelling issues needs the `api` scope and at least the Planner role in the project.

### 2. Configuration

Create a `Config.toml` file in the example's root directory with the following configurations.

```toml
token = "<Personal access token>"
serviceUrl = "https://gitlab.com/api/v4"
projectId = "<Project ID or path, e.g. 12345 or mygroup/myproject>"
triageLabel = "needs-triage"
triageLabelColor = "#f0ad4e"
applyLabels = false
```

For a self-managed GitLab instance, set `serviceUrl` to `https://<your-host>/api/v4`.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
