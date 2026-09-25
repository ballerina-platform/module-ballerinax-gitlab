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
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;

listener http:Listener ep0 = new (9090);

@http:ServiceConfig {treatNilableAsOptional: true}
service / on ep0 {
    # Delete a project
    #
    # + id - The ID or URL-encoded path of the project
    # + return - returns can be any of following types 
    # http:Accepted (Accepted)
    # http:Forbidden (Unauthenticated)
    # http:NotFound (Not found)
    # http:BadRequest (Bad Request)
    resource function delete projects/[string id]() returns http:Accepted|http:Forbidden|http:NotFound|http:BadRequest {
        return http:ACCEPTED;
    }

    # Delete an issue
    #
    # + id - The ID or URL-encoded path of the project
    # + issueIid - The internal ID of a project issue
    # + return - returns can be any of following types 
    # http:NoContent (No Content)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function delete projects/[string id]/issues/[int issueIid]() returns http:NoContent|http:NotFound|http:BadRequest {
        return http:NO_CONTENT;
    }

    # Delete a repository branch
    #
    # + id - The ID or URL-encoded path of the project
    # + branch - The name of the branch
    # + return - returns can be any of following types 
    # http:NoContent (No Content)
    # http:NotFound (Branch Not Found)
    # http:BadRequest (Bad Request)
    resource function delete projects/[string id]/repository/branches/[string branch]() returns http:NoContent|http:NotFound|http:BadRequest {
        return http:NO_CONTENT;
    }

    # List all groups
    #
    # + statistics - Include project statistics
    # + archived - Limit by archived status
    # + skipGroups - Array of group ids to exclude from list
    # + allAvailable - When `true`, returns all accessible groups. When `false`, returns only groups where the user is a member
    # + visibility - Limit by visibility
    # + search - Search for a specific group
    # + owned - Limit by owned by authenticated user
    # + orderBy - Order by name, path, id or similarity if searching
    # + sort - Sort by asc (ascending) or desc (descending)
    # + minAccessLevel - Minimum access level of authenticated user
    # + topLevelOnly - Only include top-level groups
    # + markedForDeletionOn - Return groups that are marked for deletion on this date
    # + active - Limit by groups that are not archived and not marked for deletion
    # + repositoryStorage - Filter by repository storage used by the group
    # + page - Current page number
    # + perPage - Number of items per page
    # + withCustomAttributes - Include custom attributes in the response
    # + customAttributes - Filter with custom attributes
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:BadRequest (Bad Request)
    resource function get groups(boolean? archived, @http:Query {name: "skip_groups"} int[]? skipGroups, @http:Query {name: "all_available"} boolean? allAvailable, "private"|"internal"|"public"? visibility, string? search, @http:Query {name: "min_access_level"} 10|15|20|25|30|40|50? minAccessLevel, @http:Query {name: "top_level_only"} boolean? topLevelOnly, @http:Query {name: "marked_for_deletion_on"} string? markedForDeletionOn, boolean? active, @http:Query {name: "repository_storage"} string? repositoryStorage, @http:Query {name: "custom_attributes"} record {}? customAttributes, boolean statistics = false, boolean owned = false, @http:Query {name: "order_by"} "name"|"path"|"id"|"similarity" orderBy = "name", "asc"|"desc" sort = "asc", int page = 1, @http:Query {name: "per_page"} int perPage = 20, @http:Query {name: "with_custom_attributes"} boolean withCustomAttributes = false) returns Group[]|http:BadRequest {
        return [mockGroup(), {id: 88, name: "Platform", path: "platform", fullName: "Acme / Platform", fullPath: "acme/platform", visibility: "internal", parentId: "87", webUrl: "https://gitlab.example.com/groups/acme/platform", createdAt: "2024-02-11T10:15:00.000Z"}];
    }

    # Retrieve a group
    #
    # + id - The ID of a group
    # + withCustomAttributes - Include custom attributes in the response
    # + customAttributes - Filter with custom attributes
    # + withProjects - Omit project details
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function get groups/[string id](@http:Query {name: "custom_attributes"} record {}? customAttributes, @http:Query {name: "with_custom_attributes"} boolean withCustomAttributes = false, @http:Query {name: "with_projects"} boolean withProjects = true) returns GroupDetail|http:NotFound|http:BadRequest {
        GroupDetail group = {...mockGroup()};
        group.projects = [mockProject()];
        group.sharedProjects = [];
        return group;
    }

    # List all projects
    #
    # + orderBy - Return projects ordered by field. storage_size, repository_size, wiki_size, packages_size are only available to admins. Similarity is available when searching and is limited to projects the user has access to
    # + sort - Return projects sorted in ascending and descending order
    # + archived - Limit by archived status
    # + visibility - Limit by visibility
    # + search - Return list of projects matching the search criteria
    # + searchNamespaces - Include ancestor namespaces when matching search criteria
    # + owned - Limit by owned by authenticated user
    # + starred - Limit by starred status
    # + imported - Limit by imported by authenticated user
    # + membership - Limit by projects that the current user is a member of
    # + withIssuesEnabled - Limit by enabled issues feature
    # + withMergeRequestsEnabled - Limit by enabled merge requests feature
    # + withProgrammingLanguage - Limit to repositories which use the given programming language
    # + minAccessLevel - Limit by minimum access level of authenticated user
    # + idAfter - Limit results to projects with IDs greater than the specified ID
    # + idBefore - Limit results to projects with IDs less than the specified ID
    # + lastActivityAfter - Limit results to projects with last_activity after specified time. Format: ISO 8601 YYYY-MM-DDTHH:MM:SSZ
    # + lastActivityBefore - Limit results to projects with last_activity before specified time. Format: ISO 8601 YYYY-MM-DDTHH:MM:SSZ
    # + repositoryStorage - Which storage shard the repository is on. Available only to admins
    # + topic - Comma-separated list of topics. Limit results to projects having all topics
    # + topicId - Limit results to projects with the assigned topic given by the topic ID
    # + updatedBefore - Return projects updated before the specified datetime. Format: ISO 8601 YYYY-MM-DDTHH:MM:SSZ
    # + updatedAfter - Return projects updated after the specified datetime. Format: ISO 8601 YYYY-MM-DDTHH:MM:SSZ
    # + includePendingDelete - Include projects in pending delete state. Can only be set by admins
    # + markedForDeletionOn - Date when the project was marked for deletion
    # + active - Limit by projects that are not archived and not marked for deletion
    # + wikiChecksumFailed - Limit by projects where wiki checksum is failed
    # + repositoryChecksumFailed - Limit by projects where repository checksum is failed
    # + includeHidden - Include hidden projects. Can only be set by admins
    # + page - Current page number
    # + perPage - Number of items per page
    # + simple - Return only the ID, URL, name, and path of each project
    # + statistics - Include project statistics
    # + withCustomAttributes - Include custom attributes in the response
    # + customAttributes - Filter with custom attributes
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:BadRequest (Bad request)
    resource function get projects(boolean? archived, "private"|"internal"|"public"? visibility, string? search, @http:Query {name: "search_namespaces"} boolean? searchNamespaces, @http:Query {name: "with_programming_language"} string? withProgrammingLanguage, @http:Query {name: "min_access_level"} 10|15|20|25|30|40|50? minAccessLevel, @http:Query {name: "id_after"} int? idAfter, @http:Query {name: "id_before"} int? idBefore, @http:Query {name: "last_activity_after"} string? lastActivityAfter, @http:Query {name: "last_activity_before"} string? lastActivityBefore, @http:Query {name: "repository_storage"} string? repositoryStorage, string[]? topic, @http:Query {name: "topic_id"} int? topicId, @http:Query {name: "updated_before"} string? updatedBefore, @http:Query {name: "updated_after"} string? updatedAfter, @http:Query {name: "include_pending_delete"} boolean? includePendingDelete, @http:Query {name: "marked_for_deletion_on"} string? markedForDeletionOn, boolean? active, @http:Query {name: "custom_attributes"} record {}? customAttributes, @http:Query {name: "order_by"} "id"|"name"|"path"|"created_at"|"updated_at"|"last_activity_at"|"similarity"|"star_count"|"storage_size"|"repository_size"|"wiki_size"|"packages_size" orderBy = "created_at", "asc"|"desc" sort = "desc", boolean owned = false, boolean starred = false, boolean imported = false, boolean membership = false, @http:Query {name: "with_issues_enabled"} boolean withIssuesEnabled = false, @http:Query {name: "with_merge_requests_enabled"} boolean withMergeRequestsEnabled = false, @http:Query {name: "wiki_checksum_failed"} boolean wikiChecksumFailed = false, @http:Query {name: "repository_checksum_failed"} boolean repositoryChecksumFailed = false, @http:Query {name: "include_hidden"} boolean includeHidden = false, int page = 1, @http:Query {name: "per_page"} int perPage = 20, boolean simple = false, boolean statistics = false, @http:Query {name: "with_custom_attributes"} boolean withCustomAttributes = false) returns BasicProjectDetails[]|http:BadRequest {
        return [mockProjectDetails(101, "connector-demo"), mockProjectDetails(102, "docs-site")];
    }

    # Retrieve a project
    #
    # + id - The ID or URL-encoded path of the project
    # + statistics - Include project statistics
    # + withCustomAttributes - Include custom attributes in the response
    # + customAttributes - Filter with custom attributes
    # + license - Include project license data
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id](@http:Query {name: "custom_attributes"} record {}? customAttributes, boolean statistics = false, @http:Query {name: "with_custom_attributes"} boolean withCustomAttributes = false, boolean license = false) returns ProjectsWithAccessAndCatalogSetting|http:NotFound|http:BadRequest {
        ProjectsWithAccessAndCatalogSetting project = {...mockProject()};
        project.permissions = {projectAccess: {accessLevel: "40", notificationLevel: "3"}};
        return project;
    }

    # List all project issues
    #
    # + id - The ID or URL-encoded path of the project
    # + withLabelsDetails - Return titles of labels and other details
    # + state - Return opened, closed, or all issues
    # + closedById - Return issues which were closed by the user with the given ID
    # + orderBy - Return issues ordered by `created_at`, `due_date`, `label_priority`, `milestone_due`, `popularity`, `priority`, `relative_position`, `title`, or `updated_at` fields
    # + sort - Return issues sorted in `asc` or `desc` order
    # + dueDate - Return issues that have no due date (`0`), or whose due date is this week, this month, between two weeks ago and next month, or which are overdue. Accepts: `overdue`, `week`, `month`, `next_month_and_previous_two_weeks`, `0`
    # + issueType - The type of the issue. Accepts: issue, incident, test_case, requirement, task, ticket
    # + labels - Comma-separated list of label names
    # + milestone - Milestone title. Mutually exclusive with `milestone_id`
    # + milestoneId - Return issues assigned to milestones with the specified timebox value ("Any", "None", "Upcoming" or "Started"). Mutually exclusive with `milestone`
    # + iids - The IID array of issues
    # + search - Search issues for text present in the title, description, or any combination of these
    # + 'in - `title`, `description`, or a string joining them with comma
    # + authorId - Return issues which are authored by the user with the given ID. Mutually exclusive with `author_username`
    # + authorUsername - Return issues which are authored by the user with the given username. Mutually exclusive with `author_id`
    # + assigneeId - Return issues which are assigned to the user with the given ID. Mutually exclusive with `assignee_username`
    # + assigneeUsername - Return issues which are assigned to the user with the given username. Mutually exclusive with `assignee_id`
    # + createdAfter - Return issues created after the specified time
    # + createdBefore - Return issues created before the specified time
    # + updatedAfter - Return issues updated after the specified time
    # + updatedBefore - Return issues updated before the specified time
    # + not - Filters by the specified parameters
    # + notLabels - Comma-separated list of label names
    # + notMilestone - Milestone title. Mutually exclusive with `not[milestone_id]`
    # + notMilestoneId - Return issues assigned to milestones without the specified timebox value ("Any", "None", "Upcoming" or "Started"). Mutually exclusive with `not[milestone]`
    # + notIids - The IID array of issues
    # + notAuthorId - Return issues which are not authored by the user with the given ID. Mutually exclusive with `not[author_username]`
    # + notAuthorUsername - Return issues which are not authored by the user with the given username. Mutually exclusive with `not[author_id]`
    # + notAssigneeId - Return issues which are not assigned to the user with the given ID. Mutually exclusive with `not[assignee_username]`
    # + notAssigneeUsername - Return issues which are not assigned to the user with the given username. Mutually exclusive with `not[assignee_id]`
    # + notWeight - Return issues without the specified weight
    # + notIterationId - Return issues which are not assigned to the iteration with the given ID. Mutually exclusive with `not[iteration_title]`
    # + notIterationTitle - Return issues which are not assigned to the iteration with the given title. Mutually exclusive with `not[iteration_id]`
    # + scope - Return issues for the given scope: `created_by_me`, `assigned_to_me` or `all`
    # + myReactionEmoji - Return issues reacted by the authenticated user by the given emoji
    # + confidential - Filter confidential or public issues
    # + weight - The weight of the issue
    # + epicId - The ID of an epic associated with the issues
    # + healthStatus - The health status of the issue. Must be one of: on_track, needs_attention, at_risk, none, any
    # + iterationId - Return issues which are assigned to the iteration with the given ID. Mutually exclusive with `iteration_title`
    # + iterationTitle - Return issues which are assigned to the iteration with the given title. Mutually exclusive with `iteration_id`
    # + page - Current page number
    # + perPage - Number of items per page
    # + cursor - Cursor for obtaining the next set of records
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id]/issues(@http:Query {name: "closed_by_id"} int? closedById, @http:Query {name: "due_date"} "0"|"any"|"today"|"tomorrow"|"overdue"|"week"|"month"|"next_month_and_previous_two_weeks"|""? dueDate, @http:Query {name: "issue_type"} "issue"|"incident"|"test_case"|"requirement"|"task"|"ticket"? issueType, string[]? labels, string? milestone, @http:Query {name: "milestone_id"} "Any"|"None"|"Upcoming"|"Started"? milestoneId, int[]? iids, string? search, string? 'in, @http:Query {name: "author_id"} int? authorId, @http:Query {name: "author_username"} string? authorUsername, @http:Query {name: "assignee_id"} string? assigneeId, @http:Query {name: "assignee_username"} string[]? assigneeUsername, @http:Query {name: "created_after"} string? createdAfter, @http:Query {name: "created_before"} string? createdBefore, @http:Query {name: "updated_after"} string? updatedAfter, @http:Query {name: "updated_before"} string? updatedBefore, record {}? not, @http:Query {name: "not[labels]"} string[]? notLabels, @http:Query {name: "not[milestone]"} string? notMilestone, @http:Query {name: "not[milestone_id]"} "Any"|"None"|"Upcoming"|"Started"? notMilestoneId, @http:Query {name: "not[iids]"} int[]? notIids, @http:Query {name: "not[author_id]"} int? notAuthorId, @http:Query {name: "not[author_username]"} string? notAuthorUsername, @http:Query {name: "not[assignee_id]"} int? notAssigneeId, @http:Query {name: "not[assignee_username]"} string[]? notAssigneeUsername, @http:Query {name: "not[weight]"} int? notWeight, @http:Query {name: "not[iteration_id]"} string? notIterationId, @http:Query {name: "not[iteration_title]"} string? notIterationTitle, "created-by-me"|"assigned-to-me"|"created_by_me"|"assigned_to_me"|"all"? scope, @http:Query {name: "my_reaction_emoji"} string? myReactionEmoji, boolean? confidential, string? weight, @http:Query {name: "epic_id"} string? epicId, @http:Query {name: "health_status"} "on_track"|"needs_attention"|"at_risk"|"none"|"any"? healthStatus, @http:Query {name: "iteration_id"} string? iterationId, @http:Query {name: "iteration_title"} string? iterationTitle, string? cursor, @http:Query {name: "with_labels_details"} boolean withLabelsDetails = false, "opened"|"closed"|"all" state = "all", @http:Query {name: "order_by"} "created_at"|"due_date"|"label_priority"|"milestone_due"|"popularity"|"priority"|"relative_position"|"title"|"updated_at"|"weight" orderBy = "created_at", "asc"|"desc" sort = "desc", int page = 1, @http:Query {name: "per_page"} int perPage = 20) returns Issue[]|http:NotFound|http:BadRequest {
        return [mockIssue(1, "Login page returns 500"), mockIssue(2, "Add dark mode")];
    }

    # Retrieve a project issue
    #
    # + id - The ID or URL-encoded path of the project
    # + issueIid - The internal ID of a project issue
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id]/issues/[int issueIid]() returns Issue|http:NotFound|http:BadRequest {
        return mockIssue(issueIid, "Login page returns 500");
    }

    # List all project labels
    #
    # + id - The ID or URL-encoded path of the project
    # + withCounts - Include issue and merge request counts
    # + includeAncestorGroups - Include ancestor groups
    # + search - Keyword to filter labels by. This feature was added in GitLab 13.6
    # + archived - Filter by archived status. This feature was added in GitLab 18.10
    # + page - Current page number
    # + perPage - Number of items per page
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id]/labels(string? search, boolean? archived, @http:Query {name: "with_counts"} boolean withCounts = false, @http:Query {name: "include_ancestor_groups"} boolean includeAncestorGroups = true, int page = 1, @http:Query {name: "per_page"} int perPage = 20) returns ProjectLabel[]|http:NotFound|http:BadRequest {
        return [mockLabel(11, "bug", "#d9534f"), mockLabel(12, "enhancement", "#5cb85c")];
    }

    # List all project merge requests
    #
    # + id - The ID or URL-encoded path of the project
    # + authorId - Returns merge requests created by the given user `id`. Combine with `scope=all` or `scope=assigned_to_me`. Mutually exclusive with `author_username`
    # + authorUsername - Returns merge requests created by the given `username`. Mutually exclusive with `author_id`
    # + assigneeId - Returns merge requests assigned to the given user `id`. `None` returns unassigned merge requests. `Any` returns merge requests with an assignee. Mutually exclusive with `assignee_username`
    # + assigneeUsername - Returns merge requests created by the given `username`. Mutually exclusive with `assignee_id`
    # + reviewerUsername - Returns merge requests which have the user as a reviewer with the given `username`. `None` returns merge requests with no reviewers. `Any` returns merge requests with any reviewer. Introduced in GitLab 13.8. Mutually exclusive with `reviewer_id`
    # + labels - Returns merge requests matching a comma-separated list of labels. `None` lists all merge requests with no labels. `Any` lists all merge requests with at least one label. Predefined names are case-insensitive
    # + milestone - Returns merge requests for a specific milestone. `None` returns merge requests with no milestone. `Any` returns merge requests that have an assigned milestone
    # + myReactionEmoji - Returns merge requests reacted by the authenticated user by the given `emoji`. `None` returns issues not given a reaction. `Any` returns issues given at least one reaction
    # + reviewerId - Returns merge requests which have the user as a reviewer with the given user `id`. `None` returns merge requests with no reviewers. `Any` returns merge requests with any reviewer. Mutually exclusive with `reviewer_username`
    # + state - Returns `all` merge requests or just those that are `opened`, `closed`, `locked`, or `merged`
    # + orderBy - Returns merge requests ordered by `created_at`, `label_priority`, `milestone_due`, `popularity`, `priority`, `title`, `updated_at` or `merged_at` fields. Introduced in GitLab 14.8
    # + sort - Returns merge requests sorted in `asc` or `desc` order
    # + withLabelsDetails - If `true`, response returns more details for each label in labels field: `:name`,`:color`, `:description`, `:description_html`, `:text_color`
    # + withMergeStatusRecheck - If `true`, this projection requests (but does not guarantee) that the `merge_status` field be recalculated asynchronously. Introduced in GitLab 13.0
    # + createdAfter - Returns merge requests created on or after the given time. Expected in ISO 8601 format
    # + createdBefore - Returns merge requests created on or before the given time. Expected in ISO 8601 format
    # + updatedAfter - Returns merge requests updated on or after the given time. Expected in ISO 8601 format
    # + updatedBefore - Returns merge requests updated on or before the given time. Expected in ISO 8601 format
    # + mergedAfter - Returns merge requests merged on or after the given time. Expected in ISO 8601 format
    # + mergedBefore - Returns merge requests merged on or before the given time. Expected in ISO 8601 format
    # + view - If simple, returns the `iid`, URL, title, description, and basic state of merge request
    # + scope - Returns merge requests for the given scope: `created_by_me`, `assigned_to_me`, `reviews_for_me` or `all`
    # + sourceBranch - Returns merge requests with the given source branch
    # + sourceProjectId - Returns merge requests with the given source project id
    # + targetBranch - Returns merge requests with the given target branch
    # + search - Search merge requests against their `title` and `description`
    # + 'in - Modify the scope of the search attribute. `title`, `description`, or a string joining them with comma
    # + wip - Deprecated. Use `draft` instead. Filter merge requests against their `wip` status. `yes` to return only draft merge requests, `no` to return non-draft merge requests. Mutually exclusive with `draft`
    # + draft - Filter merge requests against their `draft` status. `true` to return only draft merge requests, `false` to return non-draft merge requests. Mutually exclusive with `wip`
    # + not - Returns merge requests that do not match the parameters supplied
    # + notAuthorId - `<Negated>` Returns merge requests created by the given user `id`. Combine with `scope=all` or `scope=assigned_to_me`. Mutually exclusive with `not[author_username]`
    # + notAuthorUsername - `<Negated>` Returns merge requests created by the given `username`. Mutually exclusive with `not[author_id]`
    # + notAssigneeId - `<Negated>` Returns merge requests assigned to the given user `id`. `None` returns unassigned merge requests. `Any` returns merge requests with an assignee. Mutually exclusive with `not[assignee_username]`
    # + notAssigneeUsername - `<Negated>` Returns merge requests created by the given `username`. Mutually exclusive with `not[assignee_id]`
    # + notReviewerUsername - `<Negated>` Returns merge requests which have the user as a reviewer with the given `username`. `None` returns merge requests with no reviewers. `Any` returns merge requests with any reviewer. Introduced in GitLab 13.8. Mutually exclusive with `not[reviewer_id]`
    # + notLabels - `<Negated>` Returns merge requests matching a comma-separated list of labels. `None` lists all merge requests with no labels. `Any` lists all merge requests with at least one label. Predefined names are case-insensitive
    # + notMilestone - `<Negated>` Returns merge requests for a specific milestone. `None` returns merge requests with no milestone. `Any` returns merge requests that have an assigned milestone
    # + notMyReactionEmoji - `<Negated>` Returns merge requests reacted by the authenticated user by the given `emoji`. `None` returns issues not given a reaction. `Any` returns issues given at least one reaction
    # + notReviewerId - `<Negated>` Returns merge requests which have the user as a reviewer with the given user `id`. `None` returns merge requests with no reviewers. `Any` returns merge requests with any reviewer. Mutually exclusive with `not[reviewer_username]`
    # + deployedBefore - Returns merge requests deployed before the given date/time. Expected in ISO 8601 format
    # + deployedAfter - Returns merge requests deployed after the given date/time. Expected in ISO 8601 format
    # + environment - Returns merge requests deployed to the given environment
    # + mergeUserId - Returns merge requests which have been merged by the user with the given user `id`. Mutually exclusive with `merge_user_username`
    # + mergeUserUsername - Returns merge requests which have been merged by the user with the given `username`. Mutually exclusive with `merge_user_id`
    # + approverIds - Return merge requests which have specified the users with the given IDs as an individual approver
    # + approvedByIds - Return merge requests which have been approved by the specified users with the given IDs. Mutually exclusive with `approved_by_usernames`
    # + approvedByUsernames - Return merge requests which have been approved by the specified users with the given
    # usernames. Mutually exclusive with `approved_by_ids`
    # + page - Current page number
    # + perPage - Number of items per page
    # + iids - Returns the request having the given `iid`
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:Unauthorized (Unauthorized)
    # http:NotFound (Not found)
    # http:UnprocessableEntity (Unprocessable entity)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id]/merge_requests(@http:Query {name: "author_id"} int? authorId, @http:Query {name: "author_username"} string? authorUsername, @http:Query {name: "assignee_id"} string? assigneeId, @http:Query {name: "assignee_username"} string[]? assigneeUsername, @http:Query {name: "reviewer_username"} string? reviewerUsername, string[]? labels, string? milestone, @http:Query {name: "my_reaction_emoji"} string? myReactionEmoji, @http:Query {name: "reviewer_id"} string? reviewerId, @http:Query {name: "created_after"} string? createdAfter, @http:Query {name: "created_before"} string? createdBefore, @http:Query {name: "updated_after"} string? updatedAfter, @http:Query {name: "updated_before"} string? updatedBefore, @http:Query {name: "merged_after"} string? mergedAfter, @http:Query {name: "merged_before"} string? mergedBefore, "simple"? view, "created-by-me"|"assigned-to-me"|"created_by_me"|"assigned_to_me"|"reviews_for_me"|"all"? scope, @http:Query {name: "source_branch"} string? sourceBranch, @http:Query {name: "source_project_id"} int? sourceProjectId, @http:Query {name: "target_branch"} string? targetBranch, string? search, string? 'in, "yes"|"no"? wip, boolean? draft, record {}? not, @http:Query {name: "not[author_id]"} int? notAuthorId, @http:Query {name: "not[author_username]"} string? notAuthorUsername, @http:Query {name: "not[assignee_id]"} string? notAssigneeId, @http:Query {name: "not[assignee_username]"} string[]? notAssigneeUsername, @http:Query {name: "not[reviewer_username]"} string? notReviewerUsername, @http:Query {name: "not[labels]"} string[]? notLabels, @http:Query {name: "not[milestone]"} string? notMilestone, @http:Query {name: "not[my_reaction_emoji]"} string? notMyReactionEmoji, @http:Query {name: "not[reviewer_id]"} int? notReviewerId, @http:Query {name: "deployed_before"} string? deployedBefore, @http:Query {name: "deployed_after"} string? deployedAfter, string? environment, @http:Query {name: "merge_user_id"} int? mergeUserId, @http:Query {name: "merge_user_username"} string? mergeUserUsername, @http:Query {name: "approver_ids"} string? approverIds, @http:Query {name: "approved_by_ids"} string? approvedByIds, @http:Query {name: "approved_by_usernames"} string? approvedByUsernames, int[]? iids, "opened"|"closed"|"locked"|"merged"|"all" state = "all", @http:Query {name: "order_by"} "created_at"|"label_priority"|"milestone_due"|"popularity"|"priority"|"title"|"updated_at"|"merged_at" orderBy = "created_at", "asc"|"desc" sort = "desc", @http:Query {name: "with_labels_details"} boolean withLabelsDetails = false, @http:Query {name: "with_merge_status_recheck"} boolean withMergeStatusRecheck = false, int page = 1, @http:Query {name: "per_page"} int perPage = 20) returns MergeRequestBasic[]|http:Unauthorized|http:NotFound|http:UnprocessableEntity|http:BadRequest {
        MergeRequestBasic mr = {id: 5007, iid: 7, projectId: 101, title: "Fix login error handling", state: "opened", sourceBranch: "fix/login-500", targetBranch: "main", author: mockAuthor(), assignees: [mockUser()], reviewers: [], labels: ["bug"], draft: false, webUrl: "https://gitlab.example.com/acme/connector-demo/-/merge_requests/7", createdAt: "2026-09-20T08:00:00.000Z"};
        return [mr];
    }

    # Retrieve a merge request
    #
    # + id - The ID or URL-encoded path of the project
    # + mergeRequestIid - The internal ID of the merge request
    # + renderHtml - If `true`, response includes rendered HTML for title and description
    # + includeDivergedCommitsCount - If `true`, response includes the commits behind the target branch
    # + includeRebaseInProgress - If `true`, response includes whether a rebase operation is in progress
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (Not found)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id]/merge_requests/[int mergeRequestIid](@http:Query {name: "render_html"} boolean? renderHtml, @http:Query {name: "include_diverged_commits_count"} boolean? includeDivergedCommitsCount, @http:Query {name: "include_rebase_in_progress"} boolean? includeRebaseInProgress) returns MergeRequest|http:NotFound|http:BadRequest {
        return mockMergeRequest(mergeRequestIid, "opened");
    }

    # List all project milestones
    #
    # + id - The ID or URL-encoded path of the project
    # + state - Return "active", "closed", or "all" milestones
    # + iids - The IIDs of the milestones
    # + title - The title of the milestones
    # + search - The search criteria for the title or description of the milestone
    # + includeParentMilestones - Deprecated: see `include_ancestors`. Mutually exclusive with `include_ancestors`
    # + includeAncestors - Include milestones from all parent groups. Mutually exclusive with `include_parent_milestones`
    # + updatedBefore - Return milestones updated before the specified datetime. Format: ISO 8601 YYYY-MM-DDTHH:MM:SSZ
    # + updatedAfter - Return milestones updated after the specified datetime. Format: ISO 8601 YYYY-MM-DDTHH:MM:SSZ
    # + page - Current page number
    # + perPage - Number of items per page
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id]/milestones(int[]? iids, string? title, string? search, @http:Query {name: "include_parent_milestones"} boolean? includeParentMilestones, @http:Query {name: "include_ancestors"} boolean? includeAncestors, @http:Query {name: "updated_before"} string? updatedBefore, @http:Query {name: "updated_after"} string? updatedAfter, "active"|"closed"|"all" state = "all", int page = 1, @http:Query {name: "per_page"} int perPage = 20) returns Milestone[]|http:NotFound|http:BadRequest {
        return [{id: 301, iid: 4, projectId: 101, title: "v1.1", description: "Stabilisation release", state: "active", startDate: "2026-09-01", dueDate: "2026-10-15", expired: false, webUrl: "https://gitlab.example.com/acme/connector-demo/-/milestones/4", createdAt: "2026-08-25T09:00:00.000Z"}];
    }

    # List all releases in a project
    #
    # + id - The ID or URL-encoded path of the project
    # + page - Current page number
    # + perPage - Number of items per page
    # + orderBy - The field to use as order. Either `released_at` (default) or `created_at`
    # + sort - The direction of the order. Either `desc` (default) for descending order or `asc` for ascending order
    # + includeHtmlDescription - If `true`, a response includes HTML rendered markdown of the release description
    # + updatedBefore - Return releases updated before the specified datetime. Format: ISO 8601 YYYY-MM-DDTHH:MM:SSZ
    # + updatedAfter - Return releases updated after the specified datetime. Format: ISO 8601 YYYY-MM-DDTHH:MM:SSZ
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id]/releases(@http:Query {name: "include_html_description"} boolean? includeHtmlDescription, @http:Query {name: "updated_before"} string? updatedBefore, @http:Query {name: "updated_after"} string? updatedAfter, int page = 1, @http:Query {name: "per_page"} int perPage = 20, @http:Query {name: "order_by"} "released_at"|"created_at" orderBy = "released_at", "asc"|"desc" sort = "desc") returns Release[]|http:NotFound|http:BadRequest {
        return [mockRelease("v1.0.0")];
    }

    # List all repository branches
    #
    # + id - The ID or URL-encoded path of the project
    # + page - Current page number
    # + perPage - Number of items per page
    # + search - Return list of branches matching the search criteria
    # + regex - Return list of branches matching the regex
    # + sort - Return list of branches sorted by the given field
    # + pageToken - Name of branch to start the pagination from
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (404 Project Not Found)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id]/repository/branches(string? search, string? regex, "name_asc"|"updated_asc"|"updated_desc"? sort, @http:Query {name: "page_token"} string? pageToken, int page = 1, @http:Query {name: "per_page"} int perPage = 20) returns Branch[]|http:NotFound|http:BadRequest {
        return [mockBranch("main", true), mockBranch("fix/login-500", false)];
    }

    # Retrieve a repository branch
    #
    # + id - The ID or URL-encoded path of the project
    # + branch - The name of the branch
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (Project Not Found)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id]/repository/branches/[string branch]() returns Branch|http:NotFound|http:BadRequest {
        return mockBranch(branch, branch == "main");
    }

    # List all repository commits
    #
    # + id - The ID or URL-encoded path of the project
    # + refName - The name of a repository branch or tag, if not given the default branch is used
    # + since - Only commits after or on this date will be returned
    # + until - Only commits before or on this date will be returned
    # + path - The file path
    # + follow - Follow file renames when filtering by path
    # + author - Search commits by commit author
    # + all - Every commit will be returned
    # + withStats - Stats about each commit will be added to the response
    # + firstParent - Only include the first parent of merges
    # + 'order - List commits in order
    # + trailers - Parse and include Git trailers for every commit
    # + page - Current page number
    # + perPage - Number of items per page
    # + pagination - Specify the pagination method
    # + pageToken - Record from which to start the keyset pagination
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:BadRequest (Bad request)
    # http:Unauthorized (Unauthorized)
    # http:NotFound (Not found)
    resource function get projects/[string id]/repository/commits(@http:Query {name: "ref_name"} string? refName, string? since, string? until, string? path, boolean? follow, string? author, boolean? all, @http:Query {name: "with_stats"} boolean? withStats, @http:Query {name: "first_parent"} boolean? firstParent, @http:Query {name: "page_token"} string? pageToken, "default"|"topo" 'order = "default", boolean trailers = false, int page = 1, @http:Query {name: "per_page"} int perPage = 20, "legacy"|"keyset" pagination = "legacy") returns Commit[]|http:BadRequest|http:Unauthorized|http:NotFound {
        return [mockCommit(), {id: "4b825dc642cb6eb9a060e54bf8d69288fbee4904", shortId: "4b825dc6", title: "Initial commit", message: "Initial commit", authorName: "Jane Doe", authorEmail: "jane@acme.test", parentIds: [], committedDate: "2026-09-01T09:00:00.000Z"}];
    }

    # List all direct members of a project
    #
    # + id - The project ID
    # + query - A query string to search for members
    # + userIds - Array of user ids to look up for membership
    # + skipUsers - Array of user ids to be skipped for membership
    # + showSeatInfo - Show seat information for members
    # + withSamlIdentity - List only members with linked SAML identity
    # + page - Current page number
    # + perPage - Number of items per page
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id]/members(string? query, @http:Query {name: "user_ids"} int[]? userIds, @http:Query {name: "skip_users"} int[]? skipUsers, @http:Query {name: "show_seat_info"} boolean? showSeatInfo, @http:Query {name: "with_saml_identity"} boolean? withSamlIdentity, int page = 1, @http:Query {name: "per_page"} int perPage = 20) returns Member[]|http:NotFound|http:BadRequest {
        return [{id: 42, username: "jdoe", name: "Jane Doe", state: "active", accessLevel: "40", webUrl: "https://gitlab.example.com/jdoe", createdAt: "2024-01-15T09:30:00.000Z"}];
    }

    # List all project pipelines
    #
    # + id - The project ID or URL-encoded path
    # + page - Current page number
    # + perPage - Number of items per page
    # + scope - The scope of pipelines
    # + status - The status of pipelines
    # + ref - The ref of pipelines
    # + sha - The sha of pipelines
    # + yamlErrors - Returns pipelines with invalid configurations
    # + username - The username of the user who triggered pipelines
    # + updatedBefore - Return pipelines updated before the specified datetime. Format: ISO 8601 YYYY-MM-DDTHH:MM:SSZ
    # + updatedAfter - Return pipelines updated after the specified datetime. Format: ISO 8601 YYYY-MM-DDTHH:MM:SSZ
    # + createdBefore - Return pipelines created before the specified datetime. Format: ISO 8601 YYYY-MM-DDTHH:MM:SSZ
    # + createdAfter - Return pipelines created after the specified datetime. Format: ISO 8601 YYYY-MM-DDTHH:MM:SSZ
    # + orderBy - Order pipelines
    # + sort - Sort pipelines
    # + 'source - The source of pipelines
    # + name - Filter pipelines by name
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:Unauthorized (Unauthorized)
    # http:Forbidden (Forbidden)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id]/pipelines("running"|"pending"|"finished"|"branches"|"tags"? scope, "created"|"waiting_for_resource"|"preparing"|"waiting_for_callback"|"pending"|"running"|"success"|"failed"|"canceling"|"canceled"|"skipped"|"manual"|"scheduled"? status, string? ref, string? sha, @http:Query {name: "yaml_errors"} boolean? yamlErrors, string? username, @http:Query {name: "updated_before"} string? updatedBefore, @http:Query {name: "updated_after"} string? updatedAfter, @http:Query {name: "created_before"} string? createdBefore, @http:Query {name: "created_after"} string? createdAfter, "unknown"|"push"|"web"|"trigger"|"schedule"|"api"|"external"|"pipeline"|"chat"|"webide"|"merge_request_event"|"external_pull_request_event"|"parent_pipeline"|"ondemand_dast_scan"|"ondemand_dast_validation"|"security_orchestration_policy"|"container_registry_push"|"duo_workflow"|"pipeline_execution_policy_schedule"|"dependency_management_security_update"? 'source, string? name, int page = 1, @http:Query {name: "per_page"} int perPage = 20, @http:Query {name: "order_by"} "id"|"status"|"ref"|"updated_at"|"user_id" orderBy = "id", "asc"|"desc" sort = "desc") returns CiPipelineBasic[]|http:Unauthorized|http:Forbidden|http:NotFound|http:BadRequest {
        return [{id: 9001, iid: 31, projectId: 101, sha: "a1b2c3d4e5f60718293a4b5c6d7e8f9012345678", ref: "main", status: "success", 'source: "push", webUrl: "https://gitlab.example.com/acme/connector-demo/-/pipelines/9001", createdAt: "2026-09-24T12:00:00.000Z", updatedAt: "2026-09-24T12:06:30.000Z"}];
    }

    # Retrieve a file from a repository
    #
    # + id - The project ID
    # + filePath - The URL-encoded path to the file
    # + ref - The name of branch, tag or commit
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function get projects/[string id]/repository/files/[string filePath](string? ref) returns http:Ok|http:NotFound|http:BadRequest {
        return http:OK;
    }

    # Retrieve current user details
    #
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:Unauthorized (Unauthorized)
    # http:Forbidden (Forbidden)
    resource function get user() returns UserPublic|http:Unauthorized|http:Forbidden {
        return {id: 42, username: "jdoe", name: "Jane Doe", state: "active", email: "jane@acme.test", webUrl: "https://gitlab.example.com/jdoe", avatarUrl: "https://gitlab.example.com/uploads/-/system/user/avatar/42/avatar.png", createdAt: "2024-01-15T09:30:00.000Z", bot: false, twoFactorEnabled: true, identities: [], scimIdentities: []};
    }

    # Create a project
    #
    # + request - Request payload to create a project 
    # + return - returns can be any of following types 
    # http:Created (Created)
    # http:Forbidden (Unauthenticated)
    # http:NotFound (Not found)
    # http:BadRequest (Bad request)
    resource function post projects(http:Request request) returns Project|http:Forbidden|http:NotFound|http:BadRequest {
        return mockProject();
    }

    # Create an issue
    #
    # + id - The ID or URL-encoded path of the project
    # + payload - Request payload to create an issue 
    # + return - returns can be any of following types 
    # http:Created (Created)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function post projects/[string id]/issues(@http:Payload CreateIssueRequest payload) returns Issue|http:NotFound|http:BadRequest {
        Issue issue = mockIssue(3, payload.title ?: "Untitled issue");
        issue.description = payload?.description;
        issue.labels = payload?.labels ?: [];
        return issue;
    }

    # Create a project label
    #
    # + id - The ID or URL-encoded path of the project
    # + payload - Request payload to create a project label 
    # + return - returns can be any of following types 
    # http:Created (Created)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function post projects/[string id]/labels(@http:Payload CreateProjectLabelRequest payload) returns ProjectLabel|http:NotFound|http:BadRequest {
        return mockLabel(13, payload.name ?: "label", payload.color ?: "#428bca");
    }

    # Create a merge request
    #
    # + id - The ID or URL-encoded path of the project
    # + payload - Request payload to create a merge request 
    # + return - returns can be any of following types 
    # http:Created (Created)
    # http:BadRequest (Bad request)
    # http:Unauthorized (Unauthorized)
    # http:NotFound (Not found)
    # http:Conflict (Conflict)
    # http:UnprocessableEntity (Unprocessable entity)
    resource function post projects/[string id]/merge_requests(@http:Payload CreateMergeRequestRequest payload) returns MergeRequest|http:BadRequest|http:Unauthorized|http:NotFound|http:Conflict|http:UnprocessableEntity {
        MergeRequest mr = mockMergeRequest(8, "opened");
        mr.title = payload.title;
        mr.sourceBranch = payload.sourceBranch;
        mr.targetBranch = payload.targetBranch;
        return mr;
    }

    # Create a release
    #
    # + id - The ID or URL-encoded path of the project
    # + payload - Request payload to create a release 
    # + return - returns can be any of following types 
    # http:Created (Created)
    # http:BadRequest (Bad request)
    # http:Unauthorized (Unauthorized)
    # http:Forbidden (Forbidden)
    # http:NotFound (Not found)
    # http:Conflict (Conflict)
    # http:UnprocessableEntity (Unprocessable entity)
    resource function post projects/[string id]/releases(@http:Payload CreateReleaseRequest payload) returns Release|http:BadRequest|http:Unauthorized|http:Forbidden|http:NotFound|http:Conflict|http:UnprocessableEntity {
        return mockRelease(payload.tagName ?: "v1.1.0");
    }

    # Create a repository branch
    #
    # + id - The ID or URL-encoded path of the project
    # + payload - Request payload to create a repository branch 
    # + return - returns can be any of following types 
    # http:Created (Created)
    # http:BadRequest (Branch already exists)
    # http:NotFound (Not Found)
    resource function post projects/[string id]/repository/branches(@http:Payload CreateRepositoryBranchRequest payload) returns Branch|http:BadRequest|http:NotFound {
        return mockBranch(payload.branch ?: "feature", false);
    }

    # Create a pipeline
    #
    # + id - The project ID or URL-encoded path
    # + payload - Request payload to create a pipeline 
    # + return - returns can be any of following types 
    # http:Created (Created)
    # http:BadRequest (Bad request)
    # http:Unauthorized (Unauthorized)
    # http:Forbidden (Forbidden)
    # http:NotFound (Not found)
    resource function post projects/[string id]/pipeline(@http:Payload CreatePipelineRequest payload) returns CiPipeline|http:BadRequest|http:Unauthorized|http:Forbidden|http:NotFound {
        return {id: 9002, iid: 32, projectId: 101, sha: "a1b2c3d4e5f60718293a4b5c6d7e8f9012345678", ref: payload.ref ?: "main", status: "created", 'source: "api", tag: false, user: mockUser(), webUrl: "https://gitlab.example.com/acme/connector-demo/-/pipelines/9002", createdAt: "2026-09-25T09:00:00.000Z"};
    }

    # Update an issue
    #
    # + id - The ID or URL-encoded path of the project
    # + issueIid - The internal ID of a project issue
    # + payload - Request payload to update an issue 
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:NotFound (Not Found)
    # http:BadRequest (Bad Request)
    resource function put projects/[string id]/issues/[int issueIid](@http:Payload UpdateIssueRequest payload) returns Issue|http:NotFound|http:BadRequest {
        Issue issue = mockIssue(issueIid, payload?.title ?: "Login page returns 500");
        if payload?.stateEvent == "close" {
            issue.state = "closed";
            issue.closedAt = "2026-09-25T10:00:00.000Z";
        }
        issue.labels = payload?.labels ?: ["bug"];
        return issue;
    }

    # Merge a merge request
    #
    # + id - The ID or URL-encoded path of the project
    # + mergeRequestIid - The IID of a merge request
    # + payload - Request payload to merge a merge request 
    # + return - returns can be any of following types 
    # http:Ok (OK)
    # http:BadRequest (Bad request)
    # http:Unauthorized (Unauthorized)
    # http:NotFound (Not found)
    # http:MethodNotAllowed (Method not allowed)
    # http:Conflict (Conflict)
    # http:UnprocessableEntity (Unprocessable entity)
    resource function put projects/[string id]/merge_requests/[int mergeRequestIid]/merge(@http:Payload MergeMergeRequestRequest payload) returns MergeRequest|http:BadRequest|http:Unauthorized|http:NotFound|http:MethodNotAllowed|http:Conflict|http:UnprocessableEntity {
        MergeRequest mr = mockMergeRequest(mergeRequestIid, "merged");
        mr.mergedAt = "2026-09-25T10:30:00.000Z";
        mr.mergedBy = mockUser();
        return mr;
    }
}

isolated function mockUser() returns UserBasic => {
    id: 42,
    username: "jdoe",
    name: "Jane Doe",
    state: "active",
    locked: false,
    avatarUrl: "https://gitlab.example.com/uploads/-/system/user/avatar/42/avatar.png",
    webUrl: "https://gitlab.example.com/jdoe"
};

isolated function mockAuthor() returns MergeRequestAuthor => {
    id: 42,
    username: "jdoe",
    name: "Jane Doe",
    state: "active",
    bot: false,
    webUrl: "https://gitlab.example.com/jdoe"
};

isolated function mockNamespace() returns NamespaceBasic => {
    id: 87,
    name: "Acme",
    path: "acme",
    kind: "group",
    fullPath: "acme",
    webUrl: "https://gitlab.example.com/groups/acme"
};

isolated function mockGroup() returns Group => {
    id: 87,
    name: "Acme",
    path: "acme",
    fullName: "Acme",
    fullPath: "acme",
    description: "Acme engineering",
    visibility: "private",
    webUrl: "https://gitlab.example.com/groups/acme",
    createdAt: "2024-01-10T08:00:00.000Z",
    customAttributes: [],
    ldapGroupLinks: [],
    samlGroupLinks: []
};

isolated function mockProjectDetails(int id, string path) returns BasicProjectDetails => {
    id,
    name: path,
    path,
    nameWithNamespace: "Acme / " + path,
    pathWithNamespace: "acme/" + path,
    description: "Sample project " + path,
    defaultBranch: "main",
    visibility: "private",
    topics: ["ballerina"],
    webUrl: "https://gitlab.example.com/acme/" + path,
    httpUrlToRepo: "https://gitlab.example.com/acme/" + path + ".git",
    sshUrlToRepo: "git@gitlab.example.com:acme/" + path + ".git",
    namespace: mockNamespace(),
    starCount: 4,
    forksCount: 1,
    createdAt: "2025-03-02T14:20:00.000Z",
    lastActivityAt: "2026-09-24T12:06:30.000Z",
    customAttributes: []
};

isolated function mockProject() returns Project => {
    id: 101,
    name: "connector-demo",
    path: "connector-demo",
    nameWithNamespace: "Acme / connector-demo",
    pathWithNamespace: "acme/connector-demo",
    description: "Demo project for the GitLab connector",
    defaultBranch: "main",
    visibility: "private",
    webUrl: "https://gitlab.example.com/acme/connector-demo",
    httpUrlToRepo: "https://gitlab.example.com/acme/connector-demo.git",
    sshUrlToRepo: "git@gitlab.example.com:acme/connector-demo.git",
    namespace: mockNamespace(),
    creatorId: 42,
    createdAt: "2025-03-02T14:20:00.000Z",
    customAttributes: [],
    sharedWithGroups: []
};

isolated function mockIssue(int iid, string title) returns Issue => {
    id: 7000 + iid,
    iid,
    projectId: 101,
    title,
    description: "Steps to reproduce are in the linked logs.",
    state: "opened",
    labels: ["bug"],
    author: mockUser(),
    assignees: [mockUser()],
    confidential: false,
    upvotes: 2,
    downvotes: 0,
    webUrl: "https://gitlab.example.com/acme/connector-demo/-/issues/" + iid.toString(),
    references: {short: "#" + iid.toString(), relative: "#" + iid.toString(), full: "acme/connector-demo#" + iid.toString()},
    createdAt: "2026-09-20T07:45:00.000Z",
    updatedAt: "2026-09-24T16:10:00.000Z"
};

isolated function mockMergeRequest(int iid, string state) returns MergeRequest => {
    id: 5000 + iid,
    iid,
    projectId: 101,
    title: "Fix login error handling",
    description: "Handles the upstream timeout and returns a 503.",
    state,
    sourceBranch: "fix/login-500",
    targetBranch: "main",
    author: mockAuthor(),
    assignees: [mockUser()],
    reviewers: [mockUser()],
    labels: ["bug"],
    draft: false,
    sha: "a1b2c3d4e5f60718293a4b5c6d7e8f9012345678",
    detailedMergeStatus: "mergeable",
    hasConflicts: false,
    webUrl: "https://gitlab.example.com/acme/connector-demo/-/merge_requests/" + iid.toString(),
    createdAt: "2026-09-20T08:00:00.000Z"
};

isolated function mockCommit() returns Commit => {
    id: "a1b2c3d4e5f60718293a4b5c6d7e8f9012345678",
    shortId: "a1b2c3d4",
    title: "Fix login error handling",
    message: "Fix login error handling",
    authorName: "Jane Doe",
    authorEmail: "jane@acme.test",
    committerName: "Jane Doe",
    committerEmail: "jane@acme.test",
    parentIds: ["4b825dc642cb6eb9a060e54bf8d69288fbee4904"],
    authoredDate: "2026-09-24T11:58:00.000Z",
    committedDate: "2026-09-24T11:58:00.000Z",
    webUrl: "https://gitlab.example.com/acme/connector-demo/-/commit/a1b2c3d4e5f60718293a4b5c6d7e8f9012345678"
};

isolated function mockBranch(string name, boolean isDefault) returns Branch => {
    name,
    'commit: mockCommit(),
    merged: false,
    protected: isDefault,
    default: isDefault,
    developersCanPush: !isDefault,
    developersCanMerge: true,
    canPush: true,
    webUrl: "https://gitlab.example.com/acme/connector-demo/-/tree/" + name
};

isolated function mockLabel(int id, string name, string color) returns ProjectLabel => {
    id,
    name,
    color,
    textColor: "#FFFFFF",
    description: "Label " + name,
    openIssuesCount: 3,
    closedIssuesCount: 5,
    openMergeRequestsCount: 1,
    isProjectLabel: true,
    subscribed: false
};

isolated function mockRelease(string tagName) returns Release => {
    tagName,
    name: "Release " + tagName,
    description: "First stable release.",
    createdAt: "2026-09-01T10:00:00.000Z",
    releasedAt: "2026-09-01T10:00:00.000Z",
    author: mockUser(),
    'commit: mockCommit(),
    milestones: [],
    evidences: [],
    upcomingRelease: false
};
