# Infra & Workflow Plan

## Terraform Environments
- `infra/envs/dev`: provisions the remote-state RG/storage/container that back all Terraform operations. Hardened for public access, logging, and Azure AD auth; remains cost-optimized (LRS, no CMK/private endpoints).
- `infra/envs/prod`: placeholder; backend/provider files exist but no resources are created until the environment is explicitly enabled via CI (`TF_TARGET_ENVS`).

## CI/CD Flow
1. `tf-plan-apply` workflow (GitHub Actions) runs in matrix mode over `TF_TARGET_ENVS` (defaults to `["dev"]`).
2. Each matrix job:
   - Logs into Azure with OIDC.
   - Runs Terraform init/fmt/validate/plan under `infra/envs/<env>` using `-chdir`.
   - Executes TFLint/tfsec scoped to the same directory.
   - Uploads the per-environment plan artifact and computed exit code.
3. Apply jobs download the matching artifact, inspect the exit code, and only run `terraform apply` when changes exist and the branch is `main`.

## Security Hardening Status (Dev)
| Control | Status | Notes |
| --- | --- | --- |
| Disable public/anonymous access | ⚠️ | Blob/anonymous access flags are off and soft delete enabled, but public network access remains enabled for CI. |
| Enforce Azure AD auth only | ✅ | `shared_access_key_enabled = false`, `default_to_oauth_authentication = true`. |
| Diagnostics to Log Analytics | ✅ | Dev LA workspace with 30-day retention (aligns with current setup; adjust if cost grows). |
| Blob versioning | ✅ | Kept enabled on the dev state account to improve tfstate recovery; extra blob storage cost should stay modest for this small dev backend. |
| Checkov skips (dev) | ⚠️ | CKV2_AZURE_1, CKV_AZURE_206, CKV_AZURE_59, CKV2_AZURE_33, CKV_AZURE_33, CKV2_AZURE_21 (documented inline). |
| SAS expiration policy | ⏳ | Terraform support limited; revisit when prod environment is built. |
| Customer-managed keys | ⏳ | Requires Key Vault + key rotation; deferred for cost reasons. |
| Private endpoints | ⏳ | Adds VNets/DNS and billing overhead; hold until prod readiness. |
| Geo-redundant replication | ⏳ | LRS kept for budget; document justification in code comment. |

## Next Steps
1. Decide when to enable prod in CI by setting `TF_TARGET_ENVS` repo variable (e.g., `["dev","prod"]`), once prod resources are defined.
2. Implement SAS policy, CMK, and private endpoints when moving beyond budget-friendly dev.
3. Extend Terraform modules beyond state bootstrap (e.g., AKS module) when infrastructure scope broadens.
4. If Log Analytics cost is high in dev, consider lowering retention, switching diagnostics to a storage account, or making diagnostics optional per environment.

## ROI Priority Order (2026-03-26)

### Recommendation
- Merge the first infra PR if checks are green and there are no unresolved review comments.
- Continue the next ticket from a clean mainline instead of stacking more infra work on the same PR.
- If the next ticket is Terraform AKS, work on the module skeleton only. Do not apply a dev AKS cluster yet.
- Treat `#2`, `#5`, and `#13` as umbrella or cleanup issues; do not let them outrank the more concrete scoped issues.

### Highest ROI / lowest direct cloud cost
1. Lock the Terraform shape and close the bootstrap/docs gap:
   - `#12`, `#14`, `#35`, `#36`
2. Start reusable Terraform without provisioning more Azure resources:
   - `#1`, `#15`
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
1. Merge the current green infra PR.
2. Finish architecture/bootstrap follow-up work and reconcile legacy umbrella issues.
3. Create `infra/modules/aks` as a module skeleton only, without applying AKS in dev.
4. Tighten docs and quick-start guidance so the repo is easier to evaluate and continue from.
5. Then return to CI/CD and the smallest application skeleton work.
