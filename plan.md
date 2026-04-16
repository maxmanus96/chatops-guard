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
- `infra/modules/aks` exists as the first reusable platform module, but it is still not wired into a non-bootstrap environment root. That makes issue `#15` the real infrastructure next step, not more bootstrap repair.

## CI/CD Flow
1. `tf-plan-apply` workflow (GitHub Actions) runs in matrix mode over `TF_TARGET_ENVS` (defaults to `["dev"]`).
2. Each matrix job:
   - Logs into Azure with OIDC.
   - Runs Terraform init/fmt/validate/plan under `infra/envs/<env>` using `-chdir`.
   - Executes TFLint/tfsec scoped to the same directory.
   - Uploads the per-environment plan artifact and computed exit code.
3. Apply jobs download the matching artifact, inspect the exit code, and only run `terraform apply` when changes exist and the branch is `main`.
4. `tf-drift` is now scoped to `infra/envs/dev`, uses Azure OIDC login, and should keep stale drift issues closed when no changes exist.
5. `tf-unit-tests.yaml` now validates the live `dev` root and tolerates optional module paths, while `tf-destroy.yaml` provides a guarded manual destroy path for cost-control or teardown scenarios.

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
1. Close stale issue hygiene for delivered workflow/bootstrap work if GitHub has not already caught up, especially issue `#43`.
2. Continue issue `#15` by designing the first non-bootstrap environment wiring for AKS. Do not apply AKS in `dev` yet; decide the env-root shape first.
3. Keep AKS disabled in `infra/envs/dev`; the bootstrap root should not silently grow into the long-term platform root.
4. Only after the AKS env-root decision is settled, revisit additional dev hardening upgrades such as SAS policy, CMK, private endpoints, or GRS.

## ROI Priority Order (2026-04-16)

### Recommendation
- Treat bootstrap/state recovery and the recent workflow cleanup as done unless drift or apply proves otherwise.
- Keep AKS work on issue `#15` focused on environment wiring and explicit design decisions, not on provisioning a real cluster yet.
- Use umbrella issues such as `#2` and `#13` for tracking only; do not let them outrank the scoped implementation work.

### Highest ROI / lowest direct cloud cost
1. Continue reusable Terraform without provisioning more Azure resources:
   - `#15`
2. Improve supply-chain and project automation with mostly engineering time, not cloud spend:
   - `#28`, `#30`, `#38`, `#39`
3. Close stale issue hygiene for recently delivered work:
   - `#1`, `#43`

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
1. Reconcile issue hygiene for delivered infra and workflow work (`#1`, `#14`, `#43`).
2. Resume AKS design from the environment-wiring side instead of adding more skeleton-only hardening.
3. Keep docs aligned with the actual branch and merge state so planning does not outrun code again.
4. Then return to the smallest application skeleton work.
