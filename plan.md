# Infra & Workflow Plan

## Current State
- `infra/envs/dev` is the active Terraform bootstrap root.
- The `dev` root now successfully manages:
  - the state resource group
  - the state storage account and `tfstate` container
  - the Log Analytics workspace
  - blob-service diagnostics for the state account
- The `dev` remote state is aligned with Azure again after importing the pre-existing bootstrap resources and correcting the storage diagnostics scope.
- `infra/envs/prod` remains a dormant placeholder.
- `infra/modules/aks` exists and is merged, but it is still not wired into a non-bootstrap environment root. That makes issue `#15` the real infrastructure next step, not more bootstrap repair.

## CI/CD Flow
1. `tf-plan-apply` workflow (GitHub Actions) runs in matrix mode over `TF_TARGET_ENVS` (defaults to `["dev"]`).
2. Each matrix job:
   - Logs into Azure with OIDC.
   - Runs Terraform init/fmt/validate/plan under `infra/envs/<env>` using `-chdir`.
   - Executes TFLint/tfsec scoped to the same directory.
   - Uploads the per-environment plan artifact and computed exit code.
3. Apply jobs download the matching artifact, inspect the exit code, and only run `terraform apply` when changes exist and the branch is `main`.
4. `tf-drift` is now scoped to `infra/envs/dev` and uses Azure OIDC login, but it should still be manually run once on `main` after the recent fixes so issue `#43` and the stale drift issue `#46` can be closed with confidence.
5. `tf-unit-tests.yaml` is still legacy/root-scoped in `main`; the broader CI cleanup in draft PR `#41` remains relevant until those changes are merged or replaced.

## Security Hardening Status (Dev)
| Control | Status | Notes |
| --- | --- | --- |
| Disable public/anonymous access | ⚠️ | Blob/anonymous access flags are off and soft delete enabled, but public network access remains enabled for CI. |
| Enforce Azure AD auth only | ✅ | `shared_access_key_enabled = false`, `default_to_oauth_authentication = true`. |
| Azure AD storage provider path | ✅ | `storage_use_azuread = true` avoids key-based storage operations in Terraform. |
| Diagnostics to Log Analytics | ✅ | Dev LA workspace with 30-day retention; diagnostics now target the blob service scope Azure actually supports. |
| Blob versioning | ✅ | Kept enabled on the dev state account to improve tfstate recovery; extra blob storage cost should stay modest for this small dev backend. |
| Checkov skips (dev) | ⚠️ | CKV2_AZURE_1, CKV_AZURE_206, CKV_AZURE_59, CKV2_AZURE_33, CKV_AZURE_33, CKV2_AZURE_21 (documented inline). |
| SAS expiration policy | ⏳ | Terraform support limited; revisit when prod environment is built. |
| Customer-managed keys | ⏳ | Requires Key Vault + key rotation; deferred for cost reasons. |
| Private endpoints | ⏳ | Adds VNets/DNS and billing overhead; hold until prod readiness. |
| Geo-redundant replication | ⏳ | LRS kept for budget; document justification in code comment. |

## Next Steps
1. Manually dispatch `tf-drift` on `main` once and confirm it runs clean; then close issue `#43` and the stale drift issue `#46` if the workflow also closes them.
2. Decide whether to merge or supersede draft PR `#41`, because the current `main` branch still lacks its `tf-unit-tests` modernization and guarded `tf-destroy` workflow.
3. Continue issue `#15` by designing the first non-bootstrap environment wiring for AKS. Do not apply AKS in `dev` yet; decide the env-root shape first.
4. Only after the CI gap and AKS env-root decision are settled, revisit dev hardening upgrades such as SAS policy, CMK, private endpoints, or GRS.

## ROI Priority Order (2026-04-16)

### Recommendation
- Treat bootstrap/state recovery as done unless drift or apply proves otherwise.
- Finish the unfinished CI cleanup before opening new workflow branches.
- Keep AKS work on issue `#15` focused on environment wiring and explicit design decisions, not on provisioning a real cluster yet.
- Use umbrella issues such as `#2` and `#13` for tracking only; do not let them outrank the scoped implementation work.

### Highest ROI / lowest direct cloud cost
1. Close the CI and workflow hygiene gap:
   - PR `#41`, issue `#43`, issue `#46`
2. Continue reusable Terraform without provisioning more Azure resources:
   - `#15`
3. Improve supply-chain and project automation with mostly engineering time, not cloud spend:
   - `#28`, `#30`, `#38`, `#39`

### Medium ROI / moderate setup cost
4. Complete delivery plumbing once images and charts exist:
   - `#31`, `#32`, `#33`, `#34`, `#8`
5. Build the smallest application path that proves the platform idea:
   - `#22`, `#24`, `#27`

### Higher cost / defer until the app path is real
6. Add cost-bearing platform services only after the baseline exists:
   - `#16`, `#17`, `#18`, `#19`, `#20`, `#21`, `#29`
7. Expand user-facing and operational features after the platform is justified:
   - `#23`, `#25`, `#26`, `#37`

## Suggested Sequence
1. Verify and finish the remaining workflow cleanup (`#41`, `#43`, `#46`).
2. Reconcile issue hygiene for delivered infra work (`#1`, `#14`) vs still-active follow-up work (`#15`).
3. Resume AKS design from the environment-wiring side instead of adding more skeleton-only hardening.
4. Then return to the smallest application skeleton work.
