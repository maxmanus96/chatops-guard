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
- `infra/modules/aks` exists as the first reusable platform module.
- `infra/modules/network` now exists as a sibling module for the minimal VNet/subnet foundation.
- `infra/envs/dev-platform` is the first thin non-bootstrap platform root that composes both modules. It now has its own backend/state, has safely applied `rg-chatops-guard-platform-dev` plus the first VNet/subnet foundation, and has already completed the first local `enable_aks = true` AKS apply with a clean post-apply plan.
- `infra/envs/dev-platform` now also requires `api_server_authorized_ip_ranges` when `enable_aks = true`, so the first public dev AKS apply does not expose the API server broadly by accident.
- The first AKS rollout path is local-first: use an untracked `infra/envs/dev-platform/terraform.tfvars` for `enable_aks = true` plus a local `/32` admin IP. `dev-platform` is still intentionally outside GitHub `tf-plan-apply` for now.
- The first demo AKS rollout keeps local accounts enabled for now; disabling them is deferred into issue `#52` because AKS rejects `disableLocalAccounts=true` on Kubernetes 1.25+ clusters without managed AAD / Entra ID integration.

## CI/CD Flow
1. `tf-plan-apply` workflow (GitHub Actions) runs in matrix mode over `TF_TARGET_ENVS` (defaults to `["dev","dev-platform"]`).
2. Each matrix job:
   - Logs into Azure with OIDC.
   - Runs Terraform init/fmt/validate/plan under `infra/envs/<env>` using `-chdir`.
   - Executes TFLint/tfsec scoped to the same directory.
   - Uploads the per-environment plan artifact and computed exit code.
3. Apply jobs download the matching artifact, inspect the exit code, and only run `terraform apply` when changes exist and the branch is `main`.
4. `tf-drift` is now scoped to `infra/envs/dev`, uses Azure OIDC login, and should keep stale drift issues closed when no changes exist.
5. `tf-unit-tests.yaml` now validates the live `dev` root, `dev-platform`, and tolerates optional module paths, while `tf-destroy.yaml` provides a guarded manual destroy path for cost-control or teardown scenarios, including `dev-platform`.

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
2. Keep AKS disabled in `infra/envs/dev`; the bootstrap root should not silently grow into the long-term platform root.
3. Keep AKS disabled by default until PR #51 is reviewed and the demo-risk tradeoff is accepted.
4. Review the first GitHub runs that now include `dev-platform` and confirm the rollout behaves cleanly in Actions.
5. Track managed Entra ID integration and `disableLocalAccounts=true` under issue `#52`.
6. Then revisit additional dev hardening upgrades such as SAS policy, CMK, private endpoints, or GRS.

## ROI Priority Order (2026-04-16)

### Recommendation
- Treat bootstrap/state recovery and the recent workflow cleanup as done unless drift or apply proves otherwise.
- Treat the next AKS slice as staged environment-composition work on `infra/envs/dev-platform`: guarded root, platform RG, minimal network foundation, first real AKS plan, and only then a deliberate cluster apply.
- Use issue `#12` as the architecture anchor until a dedicated follow-up AKS env-root issue exists.
- Use umbrella issues such as `#2` and `#13` for tracking only; do not let them outrank the scoped implementation work.

### Highest ROI / lowest direct cloud cost
1. Finish the staged dev-platform rollout path and keep the new GitHub Terraform coverage stable:
   - `#12` plus `#50`
2. Improve supply-chain and project automation with mostly engineering time, not cloud spend:
   - `#28`, `#30`, `#38`, `#39`
3. Close stale issue hygiene for recently delivered work:
   - `#1`, `#15`, `#43`

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
1. Reconcile issue hygiene for delivered infra and workflow work (`#1`, `#14`, `#15`, `#43`).
2. Keep AKS work on `infra/envs/dev-platform` instead of adding more module-only hardening or mixing platform resources into `infra/envs/dev`.
3. Use the new `infra/modules/network` foundation and the existing Log Analytics workspace lookup as the demo-ready dependency path.
4. Keep PR #51 focused on the root/network/monitoring contract and the now-proven local AKS rollout.
5. Land the follow-up CI PR for issue `#53` so `dev-platform` participates in GitHub Terraform validation and plan/apply.
6. Handle managed Entra ID integration and local-account hardening in issue `#52`.
7. Keep docs aligned with the actual branch and merge state so planning does not outrun code again.
8. Then return to the smallest application skeleton work.
