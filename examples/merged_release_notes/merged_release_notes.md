# Release notes from merged merge requests

This example drafts the notes for a new release of a GitLab project. It finds the project's default branch and its most recent completed release (upcoming releases are skipped), pages through the merge requests merged into the default branch since that release, and writes one line per merge request with its author and reviewers. With `publish = true` it then creates the tag and the release from the default branch in a single call.

By default the example is a dry run: it prints the notes and creates nothing.

## Prerequisites

### 1. Set up a GitLab personal access token

Refer to the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-gitlab/blob/main/ballerina/README.md#setup-guide) to create a personal access token. The dry run needs the `read_api` scope; creating a release needs the `api` scope and at least the Developer role in the project. If the default branch is protected against tag creation, creating the release also needs permission to create tags.

### 2. Configuration

Create a `Config.toml` file in the example's root directory with the following configurations.

```toml
token = "<Personal access token>"
serviceUrl = "https://gitlab.com/api/v4"
projectId = "<Project ID or path, e.g. 12345 or mygroup/myproject>"
tagName = "<Tag for the new release, e.g. v1.4.0>"
publish = false
```

For a self-managed GitLab instance, set `serviceUrl` to `https://<your-host>/api/v4`.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
