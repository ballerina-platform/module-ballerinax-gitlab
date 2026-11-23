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

import ballerina/io;
import ballerinax/gitlab;

configurable string token = ?;
configurable string serviceUrl = "https://gitlab.com/api/v4";
configurable string projectId = ?;
configurable string triageLabel = "needs-triage";
configurable string triageLabelColor = "#f0ad4e";
// Labels are only created and applied when this is true; otherwise the run is a dry run.
configurable boolean applyLabels = false;

const int PAGE_SIZE = 100;

public function main() returns error? {
    gitlab:Client gitlabClient = check new ({auth: {privateToken: token}}, serviceUrl);

    // Step 1: collect every open issue that has no assignee, page by page.
    gitlab:Issue[] unassigned = [];
    int page = 1;
    while true {
        gitlab:Issue[] batch = check gitlabClient->listProjectIssues(projectId, state = "opened",
            assigneeId = "None", page = page, perPage = PAGE_SIZE);
        foreach gitlab:Issue issue in batch {
            // `assignees` is a list; GitLab returns an empty one for unassigned issues.
            gitlab:UserBasic[] assignees = issue.assignees ?: [];
            if assignees.length() == 0 {
                unassigned.push(issue);
            }
        }
        if batch.length() < PAGE_SIZE {
            break;
        }
        page += 1;
    }
    io:println(string `${unassigned.length()} open issue(s) have no assignee`);

    // Step 2: skip the issues that already carry the triage label.
    gitlab:Issue[] toLabel = from gitlab:Issue issue in unassigned
        where (issue.labels ?: []).indexOf(triageLabel) is ()
        select issue;
    foreach gitlab:Issue issue in toLabel {
        io:println(string `  #${issue.iid ?: 0} ${issue.title ?: ""}`);
    }

    if !applyLabels {
        io:println(string `Dry run: set applyLabels = true to label ${toLabel.length()} issue(s) with '${triageLabel}'`);
        return;
    }

    // Step 3: make sure the triage label exists in the project. `search` is a fuzzy match, so
    // check every page for the exact name.
    boolean labelExists = false;
    int labelPage = 1;
    while !labelExists {
        gitlab:ProjectLabel[] batch = check gitlabClient->listProjectLabels(projectId, search = triageLabel,
            page = labelPage, perPage = PAGE_SIZE);
        labelExists = batch.some(label => label.name == triageLabel);
        if batch.length() < PAGE_SIZE {
            break;
        }
        labelPage += 1;
    }
    if !labelExists {
        gitlab:ProjectLabel created = check gitlabClient->createProjectLabel(projectId, {
            name: triageLabel,
            color: triageLabelColor,
            description: "Open issue with no assignee, waiting for triage"
        });
        io:println(string `Created label '${created.name ?: triageLabel}'`);
    }

    // Step 4: add the label to each issue, keeping the labels it already has.
    foreach gitlab:Issue issue in toLabel {
        int? iid = issue.iid;
        if iid is () {
            return error(string `issue '${issue.title ?: ""}' has no iid`);
        }
        gitlab:Issue updated = check gitlabClient->updateIssue(projectId, iid, {addLabels: [triageLabel]});
        io:println(string `Labelled #${iid}: ${string:'join(", ", ...(updated.labels ?: []))}`);
    }
}
