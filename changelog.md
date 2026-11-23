# Change Log

This file contains all the notable changes done to the Ballerina GitLab connector through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- The connector now covers the whole GitLab REST API v4, as shipped with GitLab 19.5: **1,859 operations**, up from
  12 in 1.5.1. The new operations span projects, groups, users, issues, epics, merge requests, repositories, CI/CD,
  runners, packages and registries, security, and instance administration.
- Authentication with an OAuth 2.0 access token (`http:BearerTokenConfig`) or the OAuth 2.0 refresh-token grant
  (`OAuth2RefreshTokenGrantConfig`), in addition to the `Private-Token` header (`ApiKeysConfig`).

### Changed

- **Every public method except `getVersion()` is renamed.** The 1.5.1 methods were named after their paths and HTTP
  verbs; 2.0.0 uses stable names derived from what each operation does, and all 1,859 methods are remote methods. The
  twelve 1.5.1 methods map as follows:

  | 1.5.1 method | 2.0.0 method |
  |---|---|
  | `getVersion()` | `getVersion()` |
  | `accessrequestsprojectsGet(id)` | `listProjectAccessRequests(id)` |
  | `accessrequestsprojectsPost(id)` | `requestProjectAccess(id)` |
  | `accessrequestsprojectsapprovePut(id, userId, accessLevel)` | `approveProjectAccessRequest(id, userId, {accessLevel})` |
  | `accessrequestprojectsdenyDelete(id, userId)` | `denyProjectAccessRequest(id, userId)` |
  | `accessrequestsgroupsGet(id)` | `listGroupAccessRequests(id)` |
  | `accessrequestsgroupsPost(id)` | `requestGroupAccess(id)` |
  | `accessrequestsgroupsapprovePut(id, userId, accessLevel)` | `approveGroupAccessRequest(id, userId, {accessLevel})` |
  | `accessrequestsgroupsdenyDelete(id, userId)` | `denyGroupAccessRequest(id, userId)` |
  | `accesstokensGet(id)` | `listProjectAccessTokens(id)` |
  | `accesstokensPost(id, name, scopes, expiresAt)` | `createProjectAccessToken(id, {name, scopes, expiresAt})` |
  | `accesstokensDelete(id, tokenId)` | `revokeProjectAccessToken(id, tokenId)` |

- **Client initialisation changes.** `init(ApiKeysConfig apiKeyConfig, ConnectionConfig config = {}, string serviceUrl)`
  becomes `init(ConnectionConfig config, string serviceUrl)`, and the credentials move into `config.auth`. The
  `privateToken` field name is unchanged.
- **The default `serviceUrl` is now `https://gitlab.com/api/v4`**, up from `https://gitlab.com/api/`, so a
  self-managed instance is configured as `https://<host>/api/v4`.
- **Request bodies are passed as records.** Operations with a body take a typed payload record, so arguments that
  were individual parameters in 1.5.1 (the approval `accessLevel`, and the access token's `name`, `scopes` and
  `expiresAt`) are now fields of that record.
- **List methods return arrays.** Every `list*` method whose response is JSON returns `T[]`, e.g.
  `listProjectAccessRequests` returns `AccessRequester[]` and `listProjectAccessTokens` returns
  `ResourceAccessToken[]`; the 1.5.1 list methods declared a single record, which could not hold GitLab's list
  responses.
- **Collection-valued record fields are arrays.** Fields that GitLab returns as lists are typed as arrays, e.g.
  `Issue.assignees` and `MergeRequest.reviewers` are `UserBasic[]`, `Release.milestones` is `MilestoneWithStats[]`
  and `GroupDetail.projects` is `Project[]`.
- **Record types are renamed** to the names GitLab's API uses, e.g. `VersionResponse` is now `Metadata`,
  `ProjectAccessResponse` and `GroupAccessResponse` are now `AccessRequester`, `ProjectAccessApprove` and
  `GroupAccessApprove` are now `Member`, and `AccessToken` / `AccessTokenList` are now `ResourceAccessToken` /
  `ResourceAccessTokenWithToken`.
- Operations with no response body now return `error?` instead of `http:Response|error`.
- The minimum Ballerina distribution is now **2201.13.4** (Swan Lake Update 13), up from 2201.4.1.

Before (1.5.1):

```ballerina
gitlab:Client gitlabClient = check new ({privateToken: token});
gitlab:AccessTokenList created = check gitlabClient->accesstokensPost(projectId, "ci-bot", ["read_api"]);
```

After (2.0.0):

```ballerina
gitlab:Client gitlabClient = check new ({auth: {privateToken: token}});
gitlab:ResourceAccessTokenWithToken created = check gitlabClient->createProjectAccessToken(projectId,
    {name: "ci-bot", scopes: ["read_api"], expiresAt: "2026-12-31"});
```

### Fixed

- Revoking a project access token (`revokeProjectAccessToken`, formerly `accesstokensDelete`) now calls
  `DELETE /projects/{id}/access_tokens/{token_id}`. The 1.5.1 path ended with a stray `'`, so the request URL was
  malformed and the call could not succeed.
