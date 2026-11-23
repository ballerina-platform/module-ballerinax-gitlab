_Author_:  @DimuthuMadushan \
_Created_: 2026/09/25 \
_Updated_: 2026/09/25 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from GitLab. 
The OpenAPI specification is obtained from [wso2/api-specs](https://github.com/wso2/api-specs/blob/main/openapi/gitlab/gitlab/19.5/openapi.yaml).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. Fold GitLab's `(-/)` optional path segment into `-/`
- **Original**: 8 path keys wrote the optional dash segment literally, e.g. `/api/v4/groups/{id}/(-/)epics` and `/api/v4/groups/{id}/(-/)epics/{epic_iid}/issues/{epic_issue_id}` (15 operations; their operationIds already say `Dash`, e.g. `postApiV4GroupsIdDashEpics`).
- **Updated**: Each path is rewritten with the literal `-/` segment (`/api/v4/groups/{id}/-/epics`, ...) and merged into the existing path item of the same name. Three merged into existing path items, with no HTTP-method collision.
- **Reason**: `(-/)` is GitLab's route notation for an optional segment, not part of the URL. Left as-is, the literal `(-/)` would be sent in every request URL for these operations, and the parentheses make `bal openapi` treat the paths as complex paths.

2. Check in the specification as JSON instead of YAML
- **Original**: GitLab publishes the specification as YAML (`openapi.yaml`, 3.79 MB).
- **Updated**: `docs/spec/openapi.json` holds the same document converted to JSON (dates and timestamps kept as strings, byte-identical to the YAML scalars). No YAML copy is kept in `docs/spec/`.
- **Reason**: `bal openapi`'s YAML parser (snakeyaml) rejects documents over 3,145,728 code points ("The incoming YAML document exceeds the limit"), so every subcommand fails on the YAML with only "malformed or unreadable swagger supplied". JSON input has no such limit.

3. Add `items: {}` to array schemas that have no `items`
- **Original**: 38 `type: array` schemas declared no `items`:
    - `GET /api/v4/merge_requests` query parameter `approver_ids` (array branch of its `oneOf`)
    - `GET /api/v4/merge_requests` query parameter `approved_by_ids` (array branch of its `oneOf`)
    - `GET /api/v4/merge_requests` query parameter `approved_by_usernames` (array branch of its `oneOf`)
    - `GET /api/v4/groups/{id}/merge_requests` query parameter `approver_ids` (array branch of its `oneOf`)
    - `GET /api/v4/groups/{id}/merge_requests` query parameter `approved_by_ids` (array branch of its `oneOf`)
    - `GET /api/v4/groups/{id}/merge_requests` query parameter `approved_by_usernames` (array branch of its `oneOf`)
    - `GET /api/v4/projects/{id}/merge_requests` query parameter `approver_ids` (array branch of its `oneOf`)
    - `GET /api/v4/projects/{id}/merge_requests` query parameter `approved_by_ids` (array branch of its `oneOf`)
    - `GET /api/v4/projects/{id}/merge_requests` query parameter `approved_by_usernames` (array branch of its `oneOf`)
    - `components.schemas.APIEntitiesPersonalAccessTokenGranularScope` → `permissions`
    - `components.schemas.APIEntitiesPersonalAccessTokenWithToken` → `scopes`
    - `components.schemas.APIEntitiesGeoSite` → `selective_sync_shards`
    - `components.schemas.APIEntitiesGeoSite` → `selective_sync_namespace_ids`
    - `components.schemas.APIEntitiesGeoSite` → `selective_sync_organization_ids`
    - `components.schemas.APIEntitiesGeoNode` → `selective_sync_shards`
    - `components.schemas.APIEntitiesGeoNode` → `selective_sync_namespace_ids`
    - `components.schemas.APIEntitiesGeoNode` → `selective_sync_organization_ids`
    - `components.schemas.APIEntitiesImpersonationToken` → `scopes`
    - `components.schemas.APIEntitiesImpersonationTokenWithToken` → `scopes`
    - `components.schemas.APIEntitiesApplicationWithSecret` → `scopes`
    - `components.schemas.APIEntitiesApplication` → `scopes`
    - `components.schemas.APIEntitiesPersonalAccessToken` → `scopes`
    - `components.schemas.APIEntitiesResourceAccessTokenWithToken` → `scopes`
    - `components.schemas.APIEntitiesResourceAccessToken` → `scopes`
    - `components.schemas.APIEntitiesGlqlData` → `nodes.items`
    - `components.schemas.APIEntitiesFeatureFlag` → `scopes`
    - `components.schemas.APIEntitiesDeployToken` → `scopes`
    - `components.schemas.APIEntitiesDeployTokenWithToken` → `scopes`
    - `components.schemas.APIEntitiesSystemBroadcastMessage` → `target_access_levels`
    - `components.schemas.RequestBody_ca3de2b20bbf` → `purl_types`
    - `components.schemas.RequestBody_d75fb92cf06c` → `tags`
    - `components.schemas.RequestBody_9a3516ec87d9` → `tags`
    - `components.schemas.RequestBody_7bea2d701c3f` → `experiment_ids`
    - `components.schemas.RequestBody_51f39de64f8a` → `tags`
    - `components.schemas.RequestBody_7826876b55ea` → `tags`
    - `components.schemas.RequestBody_1aabda1af7f0` → `params.oneOf[1]`
    - `components.schemas.RequestBody_09763c4d4407` → `inputs.items.value.oneOf[1]`
    - `components.schemas.RequestBody_fb24fd84e07e` → `inputs.items.value.oneOf[1]`
- **Updated**: Each gets `items: {}`, so the element type is `anydata`.
- **Reason**: OpenAPI 3.0 requires `items` on every array schema, and `bal openapi` rejects the specification without it ("OpenAPI definition has errors"). GitLab's generator omits `items` for parameters declared as a plain Ruby `Array`. `anydata` is used for all 38 because the specification does not state the element type, and a guessed type would fail to bind whenever the guess is wrong.

4. Rename the `sbom_scan_id` path parameter to `sbom_digest`
- **Original**: `GET /api/v4/jobs/{id}/sbom_scans/{sbom_digest}` declared its second path parameter as `sbom_scan_id`, which does not appear in the path template.
- **Updated**: The parameter is renamed to `sbom_digest`, matching the template and the `POST` operation on the same path. Its type (`integer`) and description are unchanged. The request URL is unchanged.
- **Reason**: `bal openapi` rejects an operation whose `in: path` parameters do not match its path template. GitLab's generator places both routes under one template, but the `GET` still takes the SBOM scan ID.

5. Rename the `issue_id` path parameter to `epic_issue_id` on the add-issue-to-epic operation
- **Original**: `POST /api/v4/groups/{id}/-/epics/{epic_iid}/issues/{epic_issue_id}` (the folded `(-/)` path) declared its third path parameter as `issue_id` ("The ID of the issue"), which does not appear in the path template.
- **Updated**: The parameter is renamed to `epic_issue_id` and described as "The ID of the issue to assign to the epic". The request URL is unchanged.
- **Reason**: `bal openapi` rejects an operation whose `in: path` parameters do not match its path template. The `PUT` on the same path already names this segment `epic_issue_id`. For the `POST`, the segment still carries the ID of the issue being assigned to the epic, and the new description says so.

6. Send `ref` as a query parameter on the repository-file `HEAD` operations
- **Original**: `HEAD /api/v4/projects/{id}/repository/files/{file_path}` and `HEAD /api/v4/projects/{id}/repository/files/{file_path}/blame` declared a required JSON request body (`RequestBody_9b6075b1f0e7`) whose only property was `ref` (required).
- **Updated**: The request body is removed from both operations, and `ref` is added as a required `in: query` string parameter, identical to the matching `GET` operation's `ref` (description "The name of branch, tag or commit", example `main`). The orphaned `RequestBody_9b6075b1f0e7` schema is removed.
- **Reason**: A `HEAD` request cannot carry a body, and `bal openapi` rejects the specification ("HEAD operation cannot have a requestBody"). GitLab's documentation passes `ref` as a query parameter on these routes, as the `GET` operations do.

7. Give the two untyped path parameters `type: string`
- **Original**: `GET /api/v4/projects/{id}/ml/mlflow/api/2.0/mlflow-artifacts/artifacts/{model_version}/{file_path}` (parameter `file_path`) and `PUT /api/v4/projects/{id}/packages/generic/{package_name}/{package_version}/{path}/{file_name}/authorize` (parameter `path`) declared an empty parameter schema (`schema: {}`).
- **Updated**: Both schemas are `type: string`, as on every other operation that shares these path segments (for example the generic-package download and upload operations on the same path).
- **Reason**: `bal openapi --mode client` cannot map an untyped path parameter ("unsupported path parameter data type") and silently leaves both operations out of the client. A URL path segment is always a string.

8. Fix an unbalanced backtick in the child-epic `confidential` description
- **Original**: The `confidential` field of the create-child-epic request read "Parameter is ignored if `` `confidential_epics`` `` feature flag is disabled" (a stray second closing backtick).
- **Updated**: "Parameter is ignored if `confidential_epics` feature flag is disabled".
- **Reason**: The unbalanced backtick makes `bal build` warn "missing single backtick token" on the generated doc comment.

9. Return arrays from the `list*` GET operations
- **Original**: Every list endpoint declared its 2xx JSON response as a single object, e.g. `GET /api/v4/projects` → `$ref: APIEntitiesBasicProjectDetails`. None of the 1,335 upstream 2xx response schemas is an array.
- **Updated**: The 2xx `application/json` response schema of each `GET` operation whose persisted operationId (in `ai-mappings.json`) starts with `list` is wrapped as `{type: array, items: <original schema>}`. That covers 326 operations, so for example `listProjects` returns `BasicProjectDetails[]`. `listGroupPlaceholderReassignments` is excluded because its body is `text/csv`. `getProjectApprovalSettings`, `getProjectSecuritySettings` and `getGroupComposerPackagesBySha` are also not wrapped: their summaries say "list", but GitLab returns a single object for each. The `list*` `POST` operations for Conan upload URLs return a single object and are unchanged.
- **Reason**: GitLab's generator (grape-swagger) drops `is_array` from its entity documentation, so the specification types every list response as one object. GitLab returns a JSON array for these endpoints, so a client generated from the upstream types would fail to bind every list response.

10. Type collection-valued entity properties as arrays
- **Original**: 87 properties that GitLab returns as JSON arrays were declared as a single `$ref`, e.g. `APIEntitiesIssue.assignees: $ref APIEntitiesUserBasic`, so the generated records typed them as one record (`UserBasic assignees`), and every response carrying them (at least `[]`) failed to bind. Affected properties, by schema:
    - `APIEntitiesAnalyticsCodeReviewMergeRequest`: `approved_by` (APIEntitiesUserBasic)
    - `APIEntitiesApprovalSettings`: `approver_groups` (APIEntitiesApproverGroup), `approvers` (APIEntitiesApprover)
    - `APIEntitiesBasicProjectDetails`: `custom_attributes` (APIEntitiesCustomAttribute)
    - `APIEntitiesBoard`: `labels` (APIEntitiesLabelBasic)
    - `APIEntitiesBulkImportsExportStatus`: `batches` (APIEntitiesBulkImportsExportBatchStatus)
    - `APIEntitiesCiJobRequestImage`: `ports` (APIEntitiesCiJobRequestPort)
    - `APIEntitiesCiJobRequestResponse`: `artifacts` (APIEntitiesCiJobRequestArtifacts), `cache` (APIEntitiesCiJobRequestCache), `credentials` (APIEntitiesCiJobRequestCredentials), `hooks` (APIEntitiesCiJobRequestHook), `services` (APIEntitiesCiJobRequestService), `steps` (APIEntitiesCiJobRequestStep)
    - `APIEntitiesCiJobRequestService`: `ports` (APIEntitiesCiJobRequestPort)
    - `APIEntitiesCiPipelineSchedule`: `inputs` (APIEntitiesCiInput)
    - `APIEntitiesCiPipelineScheduleDetails`: `inputs` (APIEntitiesCiInput), `variables` (APIEntitiesCiVariable)
    - `APIEntitiesCiRunnerDetails`: `groups` (APIEntitiesBasicGroupDetails), `projects` (APIEntitiesBasicProjectDetails)
    - `APIEntitiesContainerRegistryRepository`: `tags` (APIEntitiesContainerRegistryTag)
    - `APIEntitiesDependency`: `licenses` (DependencyEntityLicenseEntity), `vulnerabilities` (DependencyEntityVulnerabilityEntity)
    - `APIEntitiesDeployKey`: `projects_with_readonly_access` (APIEntitiesProjectIdentity), `projects_with_write_access` (APIEntitiesProjectIdentity)
    - `APIEntitiesDeployKeysProject`: `projects_with_readonly_access` (APIEntitiesProjectIdentity), `projects_with_write_access` (APIEntitiesProjectIdentity)
    - `APIEntitiesDeploymentExtended`: `approvals` (APIEntitiesDeploymentsApproval)
    - `APIEntitiesDeploymentsApprovalSummary`: `rules` (APIEntitiesProtectedEnvironmentsApprovalRuleForSummary)
    - `APIEntitiesDiscussion`: `notes` (APIEntitiesNote)
    - `APIEntitiesEpicIssue`: `assignees` (APIEntitiesUserBasic)
    - `APIEntitiesExperimentCurrentStatus`: `gates` (APIEntitiesFeatureGate)
    - `APIEntitiesFeature`: `gates` (APIEntitiesFeatureGate)
    - `APIEntitiesFeatureFlag`: `strategies` (APIEntitiesFeatureFlagStrategy)
    - `APIEntitiesFeatureFlagStrategy`: `scopes` (APIEntitiesFeatureFlagScope)
    - `APIEntitiesGeoNodeStatus`: `namespaces` (APIEntitiesNamespaceBasic, medium confidence), `storage_shards` (StorageShardEntity)
    - `APIEntitiesGeoSiteStatus`: `namespaces` (APIEntitiesNamespaceBasic, medium confidence), `storage_shards` (StorageShardEntity)
    - `APIEntitiesGroup`: `custom_attributes` (APIEntitiesCustomAttribute), `ldap_group_links` (APIEntitiesLdapGroupLink), `saml_group_links` (APIEntitiesSamlGroupLink)
    - `APIEntitiesGroupApprovalRule`: `protected_branches` (APIEntitiesProtectedBranch)
    - `APIEntitiesGroupDetail`: `custom_attributes` (APIEntitiesCustomAttribute), `ldap_group_links` (APIEntitiesLdapGroupLink), `projects` (APIEntitiesProject), `saml_group_links` (APIEntitiesSamlGroupLink), `shared_projects` (APIEntitiesProject)
    - `APIEntitiesIssue`: `assignees` (APIEntitiesUserBasic)
    - `APIEntitiesIssueBasic`: `assignees` (APIEntitiesUserBasic)
    - `APIEntitiesMergeRequest`: `assignees` (APIEntitiesUserBasic), `reviewers` (APIEntitiesUserBasic)
    - `APIEntitiesMergeRequestApprovals`: `approved_by` (APIEntitiesApprovals)
    - `APIEntitiesMergeRequestBasic`: `assignees` (APIEntitiesUserBasic), `reviewers` (APIEntitiesUserBasic)
    - `APIEntitiesMergeRequestChanges`: `assignees` (APIEntitiesUserBasic), `reviewers` (APIEntitiesUserBasic)
    - `APIEntitiesNote`: `suggestions` (APIEntitiesSuggestion)
    - `APIEntitiesNugetSearchResult`: `versions` (APIEntitiesNugetSearchResultVersion)
    - `APIEntitiesPackage`: `pipelines` (APIEntitiesPackagePipeline), `versions` (APIEntitiesPackageVersion)
    - `APIEntitiesPackageFile`: `pipelines` (APIEntitiesPackagePipeline)
    - `APIEntitiesProject`: `custom_attributes` (APIEntitiesCustomAttribute)
    - `APIEntitiesProjectApprovalRule`: `protected_branches` (APIEntitiesProtectedBranch)
    - `APIEntitiesProjectApprovalSettingRule`: `approvers` (APIEntitiesUserBasic), `protected_branches` (APIEntitiesProtectedBranch)
    - `APIEntitiesProjectApprovalSettings`: `rules` (APIEntitiesProjectApprovalSettingRule)
    - `APIEntitiesProjectsWithAccessAndCatalogSetting`: `custom_attributes` (APIEntitiesCustomAttribute)
    - `APIEntitiesProjectsWithCatalogSetting`: `custom_attributes` (APIEntitiesCustomAttribute)
    - `APIEntitiesProtectedEnvironment`: `approval_rules` (APIEntitiesProtectedEnvironmentsApprovalRule), `deploy_access_levels` (APIEntitiesProtectedEnvironmentsDeployAccessLevel)
    - `APIEntitiesProtectedEnvironmentsApprovalRuleForSummary`: `deployment_approvals` (APIEntitiesDeploymentsApproval)
    - `APIEntitiesRelatedIssue`: `assignees` (APIEntitiesUserBasic)
    - `APIEntitiesRelease`: `evidences` (APIEntitiesReleasesEvidence), `milestones` (APIEntitiesMilestoneWithStats)
    - `APIEntitiesUserPublic`: `identities` (APIEntitiesIdentity), `scim_identities` (APIEntitiesScimIdentity)
    - `APIEntitiesUserWithAdmin`: `identities` (APIEntitiesIdentity), `scim_identities` (APIEntitiesScimIdentity)
    - `APIEntitiesVulnerabilityRelatedIssue`: `assignees` (APIEntitiesUserBasic)
    - `TestReportSummaryEntity`: `test_suites` (TestSuiteSummaryEntity)
    - `UserEntity`: `applicable_approval_rules` (APIEntitiesApprovalRuleShort)
    - `VulnerabilitiesFindingEntity`: `external_issue_links` (VulnerabilitiesExternalIssueLinkEntity), `identifiers` (VulnerabilitiesIdentifierEntity), `issue_links` (VulnerabilitiesIssueLinkEntity), `merge_request_links` (VulnerabilitiesMergeRequestLinkEntity), `state_transitions` (VulnerabilitiesStateTransitionEntity)
    - `VulnerabilitiesMergeRequestLinkEntityAuthorEntity`: `applicable_approval_rules` (APIEntitiesApprovalRuleShort)
- **Updated**: Each listed property is `{type: array, items: <original $ref>}`, keeping its `description`, `nullable` and `example`, so for example `Issue.assignees` is `UserBasic[]`. The rule is keyed on source schema + property name. The other 271 `$ref` properties were classified as single-valued and are unchanged.
- **Reason**: GitLab's generator (grape-swagger) drops `is_array` on entity exposes, so a collection exposed through an entity comes out as a single object; primitive arrays such as `labels` keep `type: array`. Each of the 358 `$ref` properties was classified from GitLab's `master` source, because there is no `19-5-stable-ee` branch yet. The evidence is the model association behind each expose (`has_many` → array; `belongs_to` / `has_one` → single), or the expose block itself where no association backs the field. The two geo `namespaces` properties are medium confidence (no direct association; the geo status entities build the list themselves).

11. Declare the API-key header as `Private-Token`
- **Original**: The `apiKey` security scheme named its header `PRIVATE-TOKEN`.
- **Updated**: The header is named `Private-Token`.
- **Reason**: HTTP header names are case-insensitive, so the request is unchanged. The generator derives the `ApiKeysConfig` field name from the header name: `PRIVATE-TOKEN` yields `pRIVATETOKEN`, while `Private-Token` yields `privateToken`, the field name the published 1.x connector used.

12. Change the `url` property of the servers object and update the API paths
- **Original**: `https://{hostname}`, with a `hostname` variable defaulting to `gitlab.com`.
- **Updated**: `https://gitlab.com/api/v4`. The variable is resolved to its default in the source specification (`https://gitlab.com`), and alignment then moves the common `/api/v4` path prefix into the base URL, removing it from every path key.
- **Reason**: `bal openapi` substitutes the variable default into the client either way, so the generated `serviceUrl` default is `https://gitlab.com/api/v4` with or without the variable; self-managed GitLab instances pass their own `serviceUrl` to `init`. The common prefix is moved into the base URL to simplify endpoint paths.

13. Known limitation: 167 `GET` operations have no 2xx response body in the specification (not changed)
- **Original**: These operations declare a 2xx response with no `content`, so the generated methods return `error?` and discard the response payload. Examples: `getRepositoryFile` (the file content and metadata), `getWorkflow`, `listWorkflowEvents`, `listGoModuleVersions` (plain-text body). The full list:
    - `authorizeAgentwUserAccess` (`GET /internal/agents/agentw/authorize_user_access`)
    - `checkConanCredentials` (`GET /packages/conan/v1/users/check_credentials`)
    - `checkConanV2Credentials` (`GET /projects/{id}/packages/conan/v2/users/check_credentials`)
    - `checkPagesAccess` (`GET /projects/{id}/pages_access`)
    - `checkProjectConanCredentials` (`GET /projects/{id}/packages/conan/v1/users/check_credentials`)
    - `downloadAttestationBundle` (`GET /projects/{id}/attestations/{attestationIid}/download`)
    - `downloadComposerArchive` (`GET /projects/{id}/packages/composer/archives/{packageName}`)
    - `downloadForwardedPypiPackageFile` (`GET /projects/{id}/packages/pypi/forward/{packageName}/{upstreamPath}`)
    - `downloadGenericPackageFile` (`GET /projects/{id}/packages/generic/{packageName}/{packageVersion}/{fileName}`)
    - `downloadGenericPackageFileInPath` (`GET /projects/{id}/packages/generic/{packageName}/{packageVersion}/{path}/{fileName}`)
    - `downloadGoModuleFile` (`GET /projects/{id}/packages/go/{moduleName}/@v/{moduleVersion}.mod`)
    - `downloadGoModuleSource` (`GET /projects/{id}/packages/go/{moduleName}/@v/{moduleVersion}.zip`)
    - `downloadGroupMavenPackageFile` (`GET /groups/{id}/-/packages/maven/{path}/{fileName}`)
    - `downloadGroupNuGetSymbolFile` (`GET /groups/{id}/-/packages/nuget/symbolfiles/{fileName}/{signature}/{sameFileName}`)
    - `downloadGroupPypiPackageFile` (`GET /groups/{id}/-/packages/pypi/files/{sha256}/{fileIdentifier}`)
    - `downloadHelmChartIndex` (`GET /projects/{id}/packages/helm/{channel}/index.yaml`)
    - `downloadInstanceMavenPackageFile` (`GET /packages/maven/{path}/{fileName}`)
    - `downloadJobArtifactFile` (`GET /projects/{id}/jobs/{jobId}/artifacts/{artifactPath}`)
    - `downloadJobArtifactFileByRef` (`GET /projects/{id}/jobs/artifacts/{refName}/raw/{artifactPath}`)
    - `downloadLicenseUsageData` (`GET /license/usage_export`)
    - `downloadMlModelPackageFile` (`GET /projects/{id}/packages/ml_models/{modelVersionId}/files/{fileName}`)
    - `downloadMlModelPackageFileInPath` (`GET /projects/{id}/packages/ml_models/{modelVersionId}/files/{path}/{fileName}`)
    - `downloadNpmTarball` (`GET /projects/{id}/packages/npm/{packageName}/-/{fileName}`)
    - `downloadNuGetPackageContent` (`GET /projects/{id}/packages/nuget/download/{packageName}/{packageVersion}/{packageFilename}`)
    - `downloadProjectMavenPackageFile` (`GET /projects/{id}/packages/maven/{path}/{fileName}`)
    - `downloadProjectNuGetSymbolFile` (`GET /projects/{id}/packages/nuget/symbolfiles/{fileName}/{signature}/{sameFileName}`)
    - `downloadProjectTerraformModule` (`GET /projects/{id}/packages/terraform/modules/{moduleName}/{moduleSystem}/{moduleVersion}`)
    - `downloadProjectTerraformModuleLatest` (`GET /projects/{id}/packages/terraform/modules/{moduleName}/{moduleSystem}`)
    - `downloadPypiPackageFile` (`GET /projects/{id}/packages/pypi/files/{sha256}/{fileIdentifier}`)
    - `downloadReleaseAsset` (`GET /projects/{id}/releases/{tagName}/downloads/{directAssetPath}`)
    - `downloadRpmPackageFile` (`GET /projects/{id}/packages/rpm/{packageFileId}/{fileName}`)
    - `downloadRpmRepositoryMetadata` (`GET /projects/{id}/packages/rpm/repodata/{fileName}`)
    - `findNuGetV2PackagesById` (`GET /projects/{projectId}/packages/nuget/v2/FindPackagesById()`)
    - `getAgentwInfo` (`GET /internal/agents/agentw/agent_info`)
    - `getAgentwServerConfig` (`GET /internal/agents/agentw/server_config`)
    - `getCargoConfig` (`GET /projects/{id}/packages/cargo/config.json`)
    - `getCodeReviewCustomInstructions` (`GET /ai/duo_workflows/code_review/custom_instructions`)
    - `getConanAuthToken` (`GET /packages/conan/v1/users/authenticate`)
    - `getConanPackageFile` (`GET /packages/conan/v1/files/{packageName}/{packageVersion}/{packageUsername}/{packageChannel}/{recipeRevision}/package/{conanPackageReference}/{packageRevision}/{fileName}`)
    - `getConanPackageReferences` (`GET /packages/conan/v1/conans/{packageName}/{packageVersion}/{packageUsername}/{packageChannel}/search`)
    - `getConanRecipeFile` (`GET /packages/conan/v1/files/{packageName}/{packageVersion}/{packageUsername}/{packageChannel}/{recipeRevision}/export/{fileName}`)
    - `getConanV2AuthToken` (`GET /projects/{id}/packages/conan/v2/users/authenticate`)
    - `getConanV2PackageFile` (`GET /projects/{id}/packages/conan/v2/conans/{packageName}/{packageVersion}/{packageUsername}/{packageChannel}/revisions/{recipeRevision}/packages/{conanPackageReference}/revisions/{packageRevision}/files/{fileName}`)
    - `getConanV2PackageReferences` (`GET /projects/{id}/packages/conan/v2/conans/{packageName}/{packageVersion}/{packageUsername}/{packageChannel}/search`)
    - `getConanV2RecipeFile` (`GET /projects/{id}/packages/conan/v2/conans/{packageName}/{packageVersion}/{packageUsername}/{packageChannel}/revisions/{recipeRevision}/files/{fileName}`)
    - `getConanV2RevisionPackageReferences` (`GET /projects/{id}/packages/conan/v2/conans/{packageName}/{packageVersion}/{packageUsername}/{packageChannel}/revisions/{recipeRevision}/search`)
    - `getCurrentUserIssuesStatistics` (`GET /issues_statistics`)
    - `getDependencyListExport` (`GET /dependency_list_exports/{exportId}`)
    - `getGeoProxyResponse` (`GET /geo/proxy`)
    - `getGlqlSchema` (`GET /glql/schema`)
    - `getGroupComposerPackageVersions` (`GET /group/{id}/-/packages/composer/{packageName}`)
    - `getGroupComposerPackagesBySha` (`GET /group/{id}/-/packages/composer/p/{sha}`)
    - `getGroupComposerUrlTemplates` (`GET /group/{id}/-/packages/composer/packages`)
    - `getGroupComposerV2PackageVersions` (`GET /group/{id}/-/packages/composer/p2/{packageName}`)
    - `getGroupDebianBinaryIndex` (`GET /groups/{id}/-/packages/debian/dists/{distribution}/{component}/binary-{architecture}/Packages`)
    - `getGroupDebianBinaryIndexByHash` (`GET /groups/{id}/-/packages/debian/dists/{distribution}/{component}/binary-{architecture}/by-hash/SHA256/{fileSha256}`)
    - `getGroupDebianInstallerIndex` (`GET /groups/{id}/-/packages/debian/dists/{distribution}/{component}/debian-installer/binary-{architecture}/Packages`)
    - `getGroupDebianInstallerIndexByHash` (`GET /groups/{id}/-/packages/debian/dists/{distribution}/{component}/debian-installer/binary-{architecture}/by-hash/SHA256/{fileSha256}`)
    - `getGroupDebianRelease` (`GET /groups/{id}/-/packages/debian/dists/{distribution}/Release`)
    - `getGroupDebianReleaseSignature` (`GET /groups/{id}/-/packages/debian/dists/{distribution}/Release.gpg`)
    - `getGroupDebianSignedRelease` (`GET /groups/{id}/-/packages/debian/dists/{distribution}/InRelease`)
    - `getGroupDebianSourceIndex` (`GET /groups/{id}/-/packages/debian/dists/{distribution}/{component}/source/Sources`)
    - `getGroupDebianSourceIndexByHash` (`GET /groups/{id}/-/packages/debian/dists/{distribution}/{component}/source/by-hash/SHA256/{fileSha256}`)
    - `getGroupDoraMetrics` (`GET /groups/{id}/dora/metrics`)
    - `getGroupIssuesStatistics` (`GET /groups/{id}/issues_statistics`)
    - `getGroupNuGetV2Metadata` (`GET /groups/{id}/-/packages/nuget/v2/$metadata`)
    - `getGroupNuGetV2ServiceIndex` (`GET /groups/{id}/-/packages/nuget/v2`)
    - `getGroupPypiPackage` (`GET /groups/{id}/-/packages/pypi/simple/{packageName}`)
    - `getLatestRelease` (`GET /projects/{id}/releases/permalink/latest`)
    - `getLatestReleaseByPath` (`GET /projects/{id}/releases/permalink/latest/{suffixPath}`)
    - `getMcpResponseListener` (`GET /mcp`)
    - `getMergeRequestDependency` (`GET /projects/{id}/merge_requests/{mergeRequestIid}/blocks/{blockId}`)
    - `getMergeRequestMergeRef` (`GET /projects/{id}/merge_requests/{mergeRequestIid}/merge_ref`)
    - `getMergeRequestRawDiffs` (`GET /projects/{id}/merge_requests/{mergeRequestIid}/raw_diffs`)
    - `getMlflowArtifactFile` (`GET /projects/{id}/ml/mlflow/api/2.0/mlflow-artifacts/artifacts/{modelVersion}/{filePath}`)
    - `getMlflowModelVersionByAlias` (`GET /projects/{id}/ml/mlflow/api/2.0/mlflow/registered-models/alias`)
    - `getNuGetV2PackageMetadata` (`GET /projects/{projectId}/packages/nuget/v2/Packages(Id='{packageName}',Version='{packageVersion}')`)
    - `getOfflineTransferExport` (`GET /offline_exports/{id}`)
    - `getOidcIdTokenClaims` (`GET /iam/userinfo`)
    - `getOrbitSchema` (`GET /orbit/schema`)
    - `getOrbitStatus` (`GET /orbit/status`)
    - `getOrgCutoverReadiness` (`GET /internal/org_mover/maintenance_readiness`)
    - `getOrgLifecycleState` (`GET /internal/org_mover/maintenance_state`)
    - `getPagesSettings` (`GET /projects/{id}/pages`)
    - `getProjectConanAuthToken` (`GET /projects/{id}/packages/conan/v1/users/authenticate`)
    - `getProjectConanPackageFile` (`GET /projects/{id}/packages/conan/v1/files/{packageName}/{packageVersion}/{packageUsername}/{packageChannel}/{recipeRevision}/package/{conanPackageReference}/{packageRevision}/{fileName}`)
    - `getProjectConanPackageReferences` (`GET /projects/{id}/packages/conan/v1/conans/{packageName}/{packageVersion}/{packageUsername}/{packageChannel}/search`)
    - `getProjectConanRecipeFile` (`GET /projects/{id}/packages/conan/v1/files/{packageName}/{packageVersion}/{packageUsername}/{packageChannel}/{recipeRevision}/export/{fileName}`)
    - `getProjectDebianBinaryIndex` (`GET /projects/{id}/packages/debian/dists/{distribution}/{component}/binary-{architecture}/Packages`)
    - `getProjectDebianBinaryIndexByHash` (`GET /projects/{id}/packages/debian/dists/{distribution}/{component}/binary-{architecture}/by-hash/SHA256/{fileSha256}`)
    - `getProjectDebianInstallerIndex` (`GET /projects/{id}/packages/debian/dists/{distribution}/{component}/debian-installer/binary-{architecture}/Packages`)
    - `getProjectDebianInstallerIndexByHash` (`GET /projects/{id}/packages/debian/dists/{distribution}/{component}/debian-installer/binary-{architecture}/by-hash/SHA256/{fileSha256}`)
    - `getProjectDebianRelease` (`GET /projects/{id}/packages/debian/dists/{distribution}/Release`)
    - `getProjectDebianReleaseSignature` (`GET /projects/{id}/packages/debian/dists/{distribution}/Release.gpg`)
    - `getProjectDebianSignedRelease` (`GET /projects/{id}/packages/debian/dists/{distribution}/InRelease`)
    - `getProjectDebianSourceIndex` (`GET /projects/{id}/packages/debian/dists/{distribution}/{component}/source/Sources`)
    - `getProjectDebianSourceIndexByHash` (`GET /projects/{id}/packages/debian/dists/{distribution}/{component}/source/by-hash/SHA256/{fileSha256}`)
    - `getProjectDoraMetrics` (`GET /projects/{id}/dora/metrics`)
    - `getProjectIssuesStatistics` (`GET /projects/{id}/issues_statistics`)
    - `getProjectLanguages` (`GET /projects/{id}/languages`)
    - `getProjectNuGetV2Metadata` (`GET /projects/{id}/packages/nuget/v2/$metadata`)
    - `getProjectNuGetV2ServiceIndex` (`GET /projects/{id}/packages/nuget/v2`)
    - `getProjectPypiPackage` (`GET /projects/{id}/packages/pypi/simple/{packageName}`)
    - `getProjectSecuritySettings` (`GET /projects/{id}/security_settings`)
    - `getRawRepositoryBlob` (`GET /projects/{id}/repository/blobs/{sha}/raw`)
    - `getRawSnippet` (`GET /snippets/{id}/raw`)
    - `getRemoteMirrorPublicKey` (`GET /projects/{id}/remote_mirrors/{mirrorId}/public_key`)
    - `getReplicableFile` (`GET /geo/retrieve/{replicableName}/{replicableId}`)
    - `getRepositoryArchive` (`GET /projects/{id}/repository/archive`)
    - `getRepositoryBlob` (`GET /projects/{id}/repository/blobs/{sha}`)
    - `getRepositoryFile` (`GET /projects/{id}/repository/files/{filePath}`)
    - `getServicePingPayload` (`GET /usage_data/service_ping`)
    - `getSidekiqJobStats` (`GET /sidekiq/job_stats`)
    - `getSnippetFileContent` (`GET /snippets/{id}/files/{ref}/{filePath}/raw`)
    - `getSwaggerDoc` (`GET /swagger_doc`)
    - `getSwaggerDocByName` (`GET /swagger_doc/{name}`)
    - `getTerraformModuleDownloadUrl` (`GET /packages/terraform/modules/v1/{moduleNamespace}/{moduleName}/{moduleSystem}/download`)
    - `getTerraformModuleVersionDownload` (`GET /packages/terraform/modules/v1/{moduleNamespace}/{moduleName}/{moduleSystem}/{moduleVersion}/download`)
    - `getTerraformState` (`GET /projects/{id}/terraform/state/{name}`)
    - `getUnleashFeatures` (`GET /feature_flags/unleash/{projectId}`)
    - `getWebCommitsPublicKey` (`GET /web_commits/public_key`)
    - `getWorkflow` (`GET /ai/duo_workflows/workflows/{id}`)
    - `getWorkflowCheckpoint` (`GET /ai/duo_workflows/workflows/{id}/checkpoints/{checkpointId}`)
    - `getWorkflowCheckpointByThread` (`GET /ai/duo_workflows/workflows/{id}/checkpoints/by_thread_ts`)
    - `getWorkflowTrace` (`GET /ai/duo_workflows/workflows/{workflowId}/trace.jsonl`)
    - `getWorkflowWebSocketConnection` (`GET /ai/duo_workflows/ws`)
    - `listAdvancedSearchMigrations` (`GET /admin/search/migrations`)
    - `listAgentPrivileges` (`GET /ai/duo_workflows/workflows/agent_privileges`)
    - `listDuoAgentPlatformTools` (`GET /ai/duo_workflows/list_tools`)
    - `listGitalyObjectPoolMembers` (`GET /internal/gitaly/object_pool_members`)
    - `listGoModuleVersions` (`GET /projects/{id}/packages/go/{moduleName}/@v/list`)
    - `listGroupHookEvents` (`GET /groups/{id}/hooks/{hookId}/events`)
    - `listGroupMilestoneBurndownEvents` (`GET /groups/{id}/milestones/{milestoneId}/burndown_events`)
    - `listGroupPersonalAccessTokens` (`GET /groups/{id}/manage/personal_access_tokens`)
    - `listGroupPypiPackages` (`GET /groups/{id}/-/packages/pypi/simple`)
    - `listGroupResourceAccessTokens` (`GET /groups/{id}/manage/resource_access_tokens`)
    - `listMergeRequestRelatedIssues` (`GET /projects/{id}/merge_requests/{mergeRequestIid}/related_issues`)
    - `listMlflowArtifacts` (`GET /projects/{id}/ml/mlflow/api/2.0/mlflow-artifacts/artifacts`)
    - `listNonSqlMetrics` (`GET /usage_data/non_sql_metrics`)
    - `listNuGetV2Packages` (`GET /projects/{projectId}/packages/nuget/v2/Packages()`)
    - `listOccurrenceVulnerabilities` (`GET /occurrences/vulnerabilities`)
    - `listOfflineTransferExports` (`GET /offline_exports`)
    - `listOrbitQueryTemplates` (`GET /orbit/query/templates`)
    - `listOrbitTools` (`GET /orbit/tools`)
    - `listPendingGroupMembers` (`GET /groups/{id}/pending_members`)
    - `listPendingMigrations` (`GET /admin/migrations/pending`)
    - `listProjectHookEvents` (`GET /projects/{id}/hooks/{hookId}/events`)
    - `listProjectMilestoneBurndownEvents` (`GET /projects/{id}/milestones/{milestoneId}/burndown_events`)
    - `listProjectPypiPackages` (`GET /projects/{id}/packages/pypi/simple`)
    - `listRunnerControllerScopes` (`GET /runner_controllers/{id}/scopes`)
    - `listServicePingSqlQueries` (`GET /usage_data/queries`)
    - `listSidekiqMetrics` (`GET /sidekiq/compound_metrics`)
    - `listSidekiqProcesses` (`GET /sidekiq/process_metrics`)
    - `listSidekiqQueueMetrics` (`GET /sidekiq/queue_metrics`)
    - `listUnleashClientFeatures` (`GET /feature_flags/unleash/{projectId}/client/features`)
    - `listUnleashFeaturesV2` (`GET /feature_flags/unleash/{projectId}/features`)
    - `listWorkflowCheckpoints` (`GET /ai/duo_workflows/workflows/{id}/checkpoints`)
    - `listWorkflowEvents` (`GET /ai/duo_workflows/workflows/{id}/events`)
    - `pingConan` (`GET /packages/conan/v1/ping`)
    - `pingProjectConan` (`GET /projects/{id}/packages/conan/v1/ping`)
    - `proxyNpmTarballDownload` (`GET /projects/{id}/dependency_proxy/packages/npm/{packageName}/-/{fileName}`)
    - `searchConanPackages` (`GET /packages/conan/v1/conans/search`)
    - `searchConanV2Packages` (`GET /projects/{id}/packages/conan/v2/conans/search`)
    - `searchGroup` (`GET /groups/{id}/-/search`)
    - `searchInstance` (`GET /search`)
    - `searchProject` (`GET /projects/{id}/-/search`)
    - `searchProjectConanPackages` (`GET /projects/{id}/packages/conan/v1/conans/search`)
- **Updated**: Nothing. No response schemas are invented.
- **Reason**: GitLab's specification does not document the response bodies of these operations, and a guessed schema would bind incorrectly whenever the guess is wrong. They are left as upstream defines them, and are recorded here so a later specification release that adds the schemas can be picked up on regeneration.

14. Known limitation: 3 operations declare only a Workhorse `file` part as their request body (not changed)
- **Original**: `POST /api/v4/projects/{id}/repository/files/{file_path}` (`createRepositoryFile`), `PUT /api/v4/projects/{id}/repository/files/{file_path}` (`updateRepositoryFile`) and `POST /api/v4/projects/{id}/repository/commits` (`createCommit`) declare a `multipart/form-data` body whose only property is `file` ("generated by Multipart middleware").
- **Updated**: Nothing. No request schema is invented.
- **Reason**: The GitLab REST API documents these endpoints as taking `branch`, `content`, `commit_message` (and, for commits, `actions`), none of which the specification declares, so the generated methods cannot send the documented request. The other multipart operations (project, group, user, topic and package uploads) declare their fields and are unaffected. Recorded so a later specification release that documents these bodies can be picked up on regeneration.

15. utils.bal serialization fixes (generated code patched after generation)
- **Original**: The `ballerina/utils.bal` that `bal openapi` 2201.13.4 generates has four serialization defects:
  1. `createFormURLEncodedRequestBody` calls `getFormStyleRequest(key, value)` for a record field without passing `encodingData.explode`, so a form field declared `explode: false` is still exploded.
  2. `createBodyParts` builds the multipart part header as the string `filename=${value.fileName}` and parses it back with `mime:getContentDispositionObject`, so a `;` in the file name starts a new parameter (`a;b=c.txt` is sent as `filename="a";b=c.txt`). `"`, CR and LF are also sent unescaped, and CR/LF can inject extra header lines.
  3. `createFormURLEncodedRequestBody`, `getDeepObjectStyleRequest`, both branches of `getFormStyleRequest` and `getSerializedRecordArray` call `pop()` on their output buffer unconditionally, which panics with `IndexOutOfRange` for an empty record or record array.
  4. A record serialized in form style with `explode: false`, as a query parameter or form field, has no `name=` prefix: `{r: 1, g: 2}` for `color` is sent as `r,1,g,2`, not `color=r,1,g,2`.
- **Updated**:
  1. The form-body record branch passes `explode`. For `explode: false` it emits `key=` followed by the non-exploded record.
  2. The file part's `ContentDisposition` object is parsed from the name-only header, and `fileName` is then set on the object, so the serializer quotes the value itself. A new helper, `getQuotedStringContent`, percent-encodes `"`, CR and LF as `%22`, `%0D` and `%0A`, as browsers do for multipart file names. `constructEntity` accepts `string|mime:ContentDisposition`.
  3. Each of those `pop()` calls is guarded with a length check, so empty input serializes to `""`, or to `parent=` for a non-exploded empty record array.
  4. `getPathForQueryParam` and the form-body branch prefix non-exploded records with `key=`. `getFormStyleRequest` itself is unchanged, because `getSerializedRecordArray` already writes the `parent=` prefix for record arrays.

- **Reason**: The defects are in the `bal openapi` utils template, not in the specification, so no specification change can fix them.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json -o ballerina --mode client --license docs/license.txt --client-methods remote
```

Note: The license year is hardcoded to 2026, change if necessary.
