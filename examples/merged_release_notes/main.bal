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
// Tag for the new release, e.g. "v1.4.0". It is created from the default branch.
configurable string tagName = ?;
// The release is only created when this is true; otherwise the notes are printed.
configurable boolean publish = false;

const int PAGE_SIZE = 100;

public function main() returns error? {
    gitlab:Client gitlabClient = check new ({auth: {privateToken: token}}, serviceUrl);

    // Step 1: find the default branch the release will be cut from.
    gitlab:ProjectsWithAccessAndCatalogSetting project = check gitlabClient->getProject(projectId);
    string? defaultBranch = project.defaultBranch;
    if defaultBranch is () {
        return error(string `project ${projectId} has no default branch`);
    }

    // Step 2: the most recent completed release marks where the new notes start. Upcoming releases
    // (released_at in the future) sort first, so page past them.
    gitlab:Release? lastRelease = ();
    int releasePage = 1;
    while lastRelease is () {
        gitlab:Release[] releases = check gitlabClient->listProjectReleases(projectId, orderBy = "released_at",
            sort = "desc", page = releasePage, perPage = PAGE_SIZE);
        foreach gitlab:Release release in releases {
            if release.upcomingRelease != true && release.releasedAt is string {
                lastRelease = release;
                break;
            }
        }
        if releases.length() < PAGE_SIZE {
            break;
        }
        releasePage += 1;
    }
    string? since = lastRelease?.releasedAt;
    io:println(lastRelease is gitlab:Release ? string `Changes since ${lastRelease.tagName ?: ""} (${since ?: ""})`
            : "No earlier release: collecting every merged merge request");

    // Step 3: collect the merge requests merged into the default branch since then.
    gitlab:MergeRequestBasic[] merged = [];
    int page = 1;
    while true {
        gitlab:MergeRequestBasic[] batch = check gitlabClient->listProjectMergeRequests(projectId,
            state = "merged", targetBranch = defaultBranch, updatedAfter = since,
            orderBy = "merged_at", page = page, perPage = PAGE_SIZE);
        foreach gitlab:MergeRequestBasic mr in batch {
            // updated_after is coarse; keep only merge requests actually merged after the release
            string? mergedAt = mr.mergedAt;
            if since is () || (mergedAt is string && mergedAt > since) {
                merged.push(mr);
            }
        }
        if batch.length() < PAGE_SIZE {
            break;
        }
        page += 1;
    }
    if merged.length() == 0 {
        io:println("Nothing was merged since the last release; no release created");
        return;
    }

    // Step 4: build the notes, one line per merge request, with its author and reviewers.
    string[] lines = [string `## ${tagName}`, ""];
    foreach gitlab:MergeRequestBasic mr in merged {
        string author = mr.author?.username ?: "unknown";
        string[] reviewers = from gitlab:UserBasic reviewer in mr.reviewers ?: []
            select "@" + (reviewer.username ?: "");
        string reviewedBy = reviewers.length() > 0 ? string ` (reviewed by ${string:'join(", ", ...reviewers)})` : "";
        lines.push(string `- ${mr.title ?: ""} !${mr.iid ?: 0} by @${author}${reviewedBy}`);
    }
    string notes = string:'join("\n", ...lines);
    io:println(notes);

    if !publish {
        io:println(string `Dry run: set publish = true to create release ${tagName} from ${defaultBranch}`);
        return;
    }

    // Step 5: create the tag and the release in one call.
    gitlab:Release release = check gitlabClient->createRelease(projectId, {
        tagName,
        ref: defaultBranch,
        name: tagName,
        description: notes
    });
    io:println(string `Created release ${release.tagName ?: tagName}`);
}
