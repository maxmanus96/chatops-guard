# Azure OIDC Least-Privilege Model

Status: staged
Date: 2026-04-25
Related issue: #62

## Why This Exists

The original bootstrap path used one Azure federated identity for both pull-request plans and main-branch applies. That is easy to start with, but it gives PR workflows the same identity as write workflows if a `pull_request` federated credential exists on that app.

The safer model is to split identities by intent:

- `AZURE_PLAN_CLIENT_ID`: read/plan/drift identity
- `AZURE_APPLY_CLIENT_ID`: apply/destroy identity
- `AZURE_CLIENT_ID`: legacy fallback while migrating

## Workflow Behavior

`tf-plan-apply.yaml` now uses:

- `AZURE_PLAN_CLIENT_ID` for Terraform plan jobs
- `AZURE_APPLY_CLIENT_ID` for Terraform apply jobs

`tf-drift.yaml` uses:

- `AZURE_PLAN_CLIENT_ID`

`tf-destroy.yaml` uses:

- `AZURE_APPLY_CLIENT_ID`

If the split secrets are not present yet, workflows fall back to `AZURE_CLIENT_ID` so the current CI/CD path keeps working during migration.

## Recommended Azure Shape

For the plan/drift identity:

- Federated credential for `repo:maxmanus96/chatops-guard:pull_request`
- Federated credential for `repo:maxmanus96/chatops-guard:ref:refs/heads/main`
- Reader on the subscription or the specific managed resource scopes
- Storage Blob Data Contributor on the Terraform state storage account so Terraform can read state and use state locking

For the apply/destroy identity:

- Federated credential for `repo:maxmanus96/chatops-guard:ref:refs/heads/main`
- No `pull_request` federated credential
- Write permissions only on scopes Terraform must manage
- Storage Blob Data Contributor on the Terraform state storage account

## Current Practical Tradeoff

This repo still has Terraform roots that manage resource groups directly. Creating or deleting resource groups can require subscription-level permissions. For that reason, fully narrowing apply permissions may need a later Terraform architecture change, such as separating subscription-level bootstrap from resource-group-scoped platform changes.

For now, the high-ROI improvement is:

1. Stop creating PR federation on the broad write identity by default.
2. Add `AZURE_PLAN_CLIENT_ID` and `AZURE_APPLY_CLIENT_ID` support in workflows.
3. Migrate Azure secrets/roles deliberately.
4. Remove the legacy `AZURE_CLIENT_ID` fallback only after split identities are proven.

## Learning Note

OIDC federation decides which GitHub workflow can become an Azure identity. Azure role assignments decide what that identity can do after login. Least privilege needs both pieces: a narrow subject and a narrow role scope.
