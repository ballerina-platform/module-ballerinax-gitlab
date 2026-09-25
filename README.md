# Ballerina GitLab connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-gitlab/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-gitlab/actions/workflows/ci.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-gitlab.svg)](https://github.com/ballerina-platform/module-ballerinax-gitlab/commits/main)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/gitlab.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%2Fgitlab)

## Overview

[GitLab](https://about.gitlab.com/) is a DevSecOps platform for source control, code review, CI/CD, issue tracking and package management, available as the gitlab.com service or as a self-managed installation.

The GitLab connector lets Ballerina applications work with projects, groups and users; issues, epics, milestones and labels; merge requests, reviews and approvals; repositories, branches, tags, commits and releases; CI/CD pipelines, jobs, runners and variables; and the package, container and model registries. It supports version 4 of the GitLab REST API, as shipped with GitLab 19.5.

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

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`gitlab` package](https://central.ballerina.io/ballerinax/gitlab/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
