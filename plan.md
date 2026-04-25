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
- The first AKS rollout path was local-first: use an untracked `infra/envs/dev-platform/terraform.tfvars` for `enable_aks = true` plus a local `/32` admin IP. That proof is now done, and `dev-platform` participates in GitHub `tf-plan-apply`.
- The current cost-aware AKS demo default is `Standard_D2as_v5`, not `Standard_D2_v2`. That is the best-ROI middle ground so far: materially cheaper than Dv2, more modern, and less memory-constrained than the ultra-cheap `A2_v2` candidate.
- The first demo AKS rollout originally kept local accounts enabled because disabling them on Kubernetes 1.25+ requires managed Entra / AAD integration. Issue `#52` wired managed Entra into Terraform so `local_account_disabled = true` is now the intended AKS-enabled path.
- For issue `#52`, the chosen access model is a dedicated Entra admin group, not an individual user object ID. That keeps AKS admin access transferable, reviewable, and easier to explain than binding cluster admin access to one person.
- Issue `#52` keeps `azure_rbac_enabled = false` in the first managed Entra slice. That is intentional: the smallest useful change is authentication hardening plus disabling local accounts; Azure RBAC role design is a separate authorization rollout.

## CI/CD Flow
1. `tf-plan-apply` workflow (GitHub Actions) runs in matrix mode over `TF_TARGET_ENVS` (defaults to `["dev","dev-platform"]`).
2. Each matrix job:
   - Logs into Azure with OIDC.
   - Runs Terraform init/fmt/validate/plan under `infra/envs/<env>` using `-chdir`.
   - Executes TFLint/tfsec scoped to the same directory.
   - Uploads the per-environment plan artifact and computed exit code.
3. Apply jobs download the matching artifact, inspect the exit code, and only run `terraform apply` when changes exist and the branch is `main`.
4. `tf-drift` now runs in matrix mode for `dev` and `dev-platform`, uses Azure OIDC login, and creates or closes environment-specific drift issues.
5. `pr-quality.yaml` provides static automated PR review without Azure login: workflow linting via `actionlint` plus Terraform `fmt/init/validate` over the active roots/modules.
6. Dependabot is enabled for GitHub Actions and Terraform provider updates so dependency bumps arrive as reviewable PRs instead of silent drift.
7. `tf-unit-tests.yaml` now validates the live `dev` root, `dev-platform`, and tolerates optional module paths, while `tf-destroy.yaml` provides a guarded manual destroy path for cost-control or teardown scenarios, including `dev-platform`.

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
1. Refresh local Azure auth with `az login` before making any live cost claim about AKS or VMSS resources.
2. Keep AKS disabled in `infra/envs/dev`; the bootstrap root should not silently grow into the long-term platform root.
3. Keep AKS disabled by default for cost control unless there is an active demo/learning session and a clear teardown plan.
4. Merge PR `#59` for issue `#55`, then watch the first scheduled/manual drift run to confirm separate drift issues per environment.
5. Merge the issue `#60` static PR quality gate so workflow/Terraform syntax mistakes are caught before human review.
6. Close stale issue hygiene for delivered workflow/bootstrap work if GitHub has not already caught up, especially issue `#43`.
7. Then revisit additional dev hardening upgrades such as SAS policy, CMK, private endpoints, or GRS.

## ROI Priority Order (2026-04-25)

### Recommendation
- Treat bootstrap/state recovery and the recent workflow cleanup as done unless drift or apply proves otherwise.
- Treat the next AKS slice as controlled rollout work on `infra/envs/dev-platform`: keep the tracked default off, enable AKS only when needed, and destroy/disable it after demos if budget matters more than always-on availability.
- Use issue `#12` as the architecture anchor until a dedicated follow-up AKS env-root issue exists.
- Use umbrella issues such as `#2` and `#13` for tracking only; do not let them outrank the scoped implementation work.

### Highest ROI / lowest direct cloud cost
1. Finish the staged dev-platform rollout path and keep the new GitHub Terraform coverage stable:
   - `#12`, `#50`, `#53`, `#55`
2. Improve supply-chain and project automation with mostly engineering time, not cloud spend:
   - `#28`, `#30`, `#38`, `#39`, `#60`
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
4. Keep AKS cost controlled: `enable_aks = false` remains the repo default, and intentional enables need an explicit teardown path.
5. After PR `#59` merges, verify scheduled drift detection covers both active Terraform roots without cross-closing issues.
6. Keep docs aligned with the actual branch and merge state so planning does not outrun code again.
7. Then return to the smallest application skeleton work.
