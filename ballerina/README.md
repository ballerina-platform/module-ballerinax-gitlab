## Overview

[GitLab](https://about.gitlab.com/) is a DevSecOps platform for source control, code review, CI/CD, issue tracking and package management, available as the gitlab.com service or as a self-managed installation.

The GitLab connector lets Ballerina applications work with projects, groups and users; issues, epics, milestones and labels; merge requests, reviews and approvals; repositories, branches, tags, commits and releases; CI/CD pipelines, jobs, runners and variables; and the package, container and model registries. It supports version 4 of the GitLab REST API, as shipped with GitLab 19.5.

### Key features

- Manage projects, groups, members and access tokens
- Track work with issues, epics, milestones, labels and boards
- Review and merge code with merge requests, discussions and approvals
- Work with repositories, branches, tags, commits and releases
- Run and monitor CI/CD pipelines, jobs, runners and environments
- Publish and consume packages across the GitLab package registries

## Setup guide

To use the GitLab connector you need a GitLab account on [gitlab.com](https://gitlab.com/users/sign_up) or on a self-managed GitLab instance, and a token the connector sends with every request. The simplest is a personal access token.

### Step 1: Create a personal access token

1. Sign in to GitLab.

2. Select your avatar in the left sidebar, then **Edit profile**.

3. In the left sidebar, select **Access tokens** (under **User settings**), then **Add new token**.

4. Enter a name and an expiry date, and select the scopes the application needs:
   * `api` for full read and write access
   * `read_api` for read-only access

5. Select **Create personal access token** and copy the token. GitLab shows it only once.

Group and project access tokens (**Settings → Access tokens** in a group or project) are used the same way, and limit the token to that group or project.

### Step 2: Note the API base URL

The connector targets `https://gitlab.com/api/v4` by default. For a self-managed instance, the base URL is `https://<your-gitlab-host>/api/v4`.

The connector also accepts an OAuth 2.0 access token (`auth: {token: "<access token>"}`) or the OAuth 2.0 refresh-token grant, for applications registered under **User settings → Applications**.

## Quickstart

To use the GitLab connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

Import the `gitlab` module.

```ballerina
import ballerinax/gitlab;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the token obtained in the steps above:

```toml
token = "<Personal access token>"
projectId = "<Project ID or path, e.g. 12345 or mygroup/myproject>"
```

2. Create a `gitlab:ConnectionConfig` with the token and initialize the connector with it. Pass the base URL as the second argument for a self-managed instance.

```ballerina
configurable string token = ?;
configurable string projectId = ?;

final gitlab:Client gitlabClient = check new ({
    auth: {
        privateToken: token
    }
});
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

#### List the open issues of a project

```ballerina
public function main() returns error? {
    gitlab:Issue[] _ = check gitlabClient->listProjectIssues(projectId, state = "opened");
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The GitLab connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-gitlab/tree/main/examples/), covering the following use cases:

1. [Unassigned issue triage](https://github.com/ballerina-platform/module-ballerinax-gitlab/tree/main/examples/unassigned_issue_triage) - Find every open issue with no assignee and mark it for triage with a label, creating the label if the project does not have it.

2. [Release notes from merged merge requests](https://github.com/ballerina-platform/module-ballerinax-gitlab/tree/main/examples/merged_release_notes) - Collect the merge requests merged into the default branch since the last release, draft notes crediting authors and reviewers, and publish the release.
