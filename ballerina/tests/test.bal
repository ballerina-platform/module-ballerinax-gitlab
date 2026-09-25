// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/os;
import ballerina/test;
import ballerina/time;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
final string serviceUrl = isLiveServer ? os:getEnv("GITLAB_URL") : "http://localhost:9090";
final string token = isLiveServer ? os:getEnv("GITLAB_TOKEN") : "test-token";
final string projectId = isLiveServer ? os:getEnv("GITLAB_PROJECT_ID") : "101";
final string groupId = isLiveServer ? os:getEnv("GITLAB_GROUP_ID") : "87";
final string namespaceId = isLiveServer ? os:getEnv("GITLAB_NAMESPACE_ID") : "87";

// The mock listener is plain HTTP/1.1; live calls use the default HTTP/2 client.
final Client gitlab = check new ({
    auth: {privateToken: token},
    httpVersion: isLiveServer ? http:HTTP_2_0 : http:HTTP_1_1
}, serviceUrl);

// Live fixtures need unique names; against the mock the name is used as given.
isolated function fixture(string name) returns string =>
    isLiveServer ? string `${name}-${time:utcNow()[0]}` : name;

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetCurrentUser() returns error? {
    UserPublic user = check gitlab->getCurrentUser();
    test:assertTrue(user.id !is ());
    test:assertTrue(user.username !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListProjects() returns error? {
    BasicProjectDetails[] projects = check gitlab->listProjects(membership = true, perPage = 5);
    test:assertTrue(projects.length() > 0);
    test:assertTrue(projects[0].id !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetProject() returns error? {
    ProjectsWithAccessAndCatalogSetting project = check gitlab->getProject(projectId);
    test:assertEquals(project.id.toString(), projectId);
    test:assertTrue(project.webUrl !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testCreateProject() returns error? {
    string name = fixture("connector-test-project");
    Project project = check gitlab->createProject({name, path: name, namespaceId: check int:fromString(namespaceId)});
    test:assertTrue(project.id !is ());
    if isLiveServer {
        check gitlab->deleteProject(<int>project.id);
    }
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testDeleteProject() returns error? {
    string name = fixture("connector-delete-project");
    Project project = check gitlab->createProject({name, path: name, namespaceId: check int:fromString(namespaceId)});
    int? id = project.id;
    if id is () {
        return error("createProject returned no id");
    }
    error? result = gitlab->deleteProject(id);
    test:assertTrue(result is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListGroups() returns error? {
    Group[] groups = check gitlab->listGroups(perPage = 5);
    test:assertTrue(groups.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetGroup() returns error? {
    GroupDetail group = check gitlab->getGroup(groupId, withProjects = false);
    test:assertEquals(group.id.toString(), groupId);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListProjectMembers() returns error? {
    Member[] members = check gitlab->listProjectMembers(projectId);
    test:assertTrue(members.length() > 0);
    test:assertTrue(members[0].username !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testCreateIssue() returns error? {
    Issue issue = check gitlab->createIssue(projectId, {
        title: "Login page returns 500",
        description: "Created by the GitLab connector tests.",
        labels: ["bug"]
    });
    test:assertTrue(issue.iid !is ());
    test:assertEquals(issue.title, "Login page returns 500");
    UserBasic[]? assignees = issue.assignees;
    test:assertTrue(assignees is UserBasic[] || assignees is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListProjectIssues() returns error? {
    Issue[] issues = check gitlab->listProjectIssues(projectId, state = "all", perPage = 10);
    test:assertTrue(issues.length() > 0);
    // entity collections are arrays: every issue carries an assignee list (possibly empty)
    test:assertTrue(issues[0].assignees is UserBasic[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetProjectIssue() returns error? {
    Issue created = check gitlab->createIssue(projectId, {title: "Issue to read back"});
    int iid = check created.iid.ensureType();
    Issue issue = check gitlab->getProjectIssue(projectId, iid);
    test:assertEquals(issue.iid, iid);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testUpdateIssue() returns error? {
    Issue created = check gitlab->createIssue(projectId, {title: "Issue to close"});
    int iid = check created.iid.ensureType();
    Issue issue = check gitlab->updateIssue(projectId, iid, {stateEvent: "close", labels: ["bug", "resolved"]});
    test:assertEquals(issue.state, "closed");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testDeleteIssue() returns error? {
    Issue created = check gitlab->createIssue(projectId, {title: "Issue to delete"});
    int? iid = created.iid;
    if iid is () {
        return error("createIssue returned no iid");
    }
    error? result = gitlab->deleteIssue(projectId, iid);
    test:assertTrue(result is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListProjectLabels() returns error? {
    ProjectLabel[] labels = check gitlab->listProjectLabels(projectId);
    test:assertTrue(labels is ProjectLabel[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testCreateProjectLabel() returns error? {
    string name = fixture("connector-label");
    ProjectLabel label = check gitlab->createProjectLabel(projectId, {name, color: "#428bca"});
    test:assertEquals(label.name, name);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListProjectMilestones() returns error? {
    Milestone[] milestones = check gitlab->listProjectMilestones(projectId);
    test:assertTrue(milestones is Milestone[]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListRepositoryBranches() returns error? {
    Branch[] branches = check gitlab->listRepositoryBranches(projectId);
    test:assertTrue(branches.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetRepositoryBranch() returns error? {
    Branch branch = check gitlab->getRepositoryBranch(projectId, "main");
    test:assertEquals(branch.name, "main");
    test:assertTrue(branch.'commit?.id !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testCreateRepositoryBranch() returns error? {
    string name = fixture("connector-branch");
    Branch branch = check gitlab->createRepositoryBranch(projectId, {branch: name, ref: "main"});
    test:assertEquals(branch.name, name);
    if isLiveServer {
        check gitlab->deleteRepositoryBranch(projectId, name);
    }
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testDeleteRepositoryBranch() returns error? {
    string name = fixture("connector-branch-to-delete");
    Branch branch = check gitlab->createRepositoryBranch(projectId, {branch: name, ref: "main"});
    test:assertEquals(branch.name, name);
    error? result = gitlab->deleteRepositoryBranch(projectId, name);
    test:assertTrue(result is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListRepositoryCommits() returns error? {
    Commit[] commits = check gitlab->listRepositoryCommits(projectId, refName = "main", perPage = 5);
    test:assertTrue(commits.length() > 0);
    test:assertTrue(commits[0].id !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetRepositoryFile() returns error? {
    // The specification documents no response body for this operation, so only the
    // call's success is observable.
    error? result = gitlab->getRepositoryFile(projectId, "README.md", ref = "main");
    test:assertTrue(result is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListProjectMergeRequests() returns error? {
    MergeRequestBasic[] mergeRequests = check gitlab->listProjectMergeRequests(projectId, state = "all");
    test:assertTrue(mergeRequests is MergeRequestBasic[]);
}

// Creating and merging a merge request needs a source branch that differs from the
// target, which a test cannot set up on its own; these run against the mock only.
@test:Config {groups: ["mock_tests"]}
function testCreateMergeRequest() returns error? {
    MergeRequest mr = check gitlab->createMergeRequest(projectId, {
        title: "Fix login error handling",
        sourceBranch: "fix/login-500",
        targetBranch: "main"
    });
    test:assertEquals(mr.sourceBranch, "fix/login-500");
    test:assertTrue(mr.reviewers is UserBasic[]);
}

@test:Config {groups: ["mock_tests"]}
function testGetMergeRequest() returns error? {
    MergeRequest mr = check gitlab->getMergeRequest(projectId, 7);
    test:assertEquals(mr.iid, 7);
    test:assertEquals(mr.state, "opened");
}

@test:Config {groups: ["mock_tests"]}
function testMergeMergeRequest() returns error? {
    MergeRequest mr = check gitlab->mergeMergeRequest(projectId, 7, {shouldRemoveSourceBranch: true});
    test:assertEquals(mr.state, "merged");
    test:assertTrue(mr.mergedAt !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListProjectPipelines() returns error? {
    CiPipelineBasic[] pipelines = check gitlab->listProjectPipelines(projectId, perPage = 5);
    test:assertTrue(pipelines is CiPipelineBasic[]);
}

// A pipeline can only be created in a project with a CI configuration; mock only.
@test:Config {groups: ["mock_tests"]}
function testCreatePipeline() returns error? {
    CiPipeline pipeline = check gitlab->createPipeline(projectId, {ref: "main"});
    test:assertEquals(pipeline.ref, "main");
    test:assertTrue(pipeline.id !is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListProjectReleases() returns error? {
    Release[] releases = check gitlab->listProjectReleases(projectId);
    test:assertTrue(releases is Release[]);
}

// Creating a release creates a tag in the repository; mock only.
@test:Config {groups: ["mock_tests"]}
function testCreateRelease() returns error? {
    Release release = check gitlab->createRelease(projectId, {tagName: "v1.1.0", ref: "main", name: "v1.1.0"});
    test:assertEquals(release.tagName, "v1.1.0");
}
