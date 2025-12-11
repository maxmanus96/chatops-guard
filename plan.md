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
| SAS expiration policy | ⏳ | Terraform support limited; revisit when prod environment is built. |
| Customer-managed keys | ⏳ | Requires Key Vault + key rotation; deferred for cost reasons. |
| Private endpoints | ⏳ | Adds VNets/DNS and billing overhead; hold until prod readiness. |
| Geo-redundant replication | ⏳ | LRS kept for budget; document justification in code comment. |

## Next Steps
1. Decide when to enable prod in CI by setting `TF_TARGET_ENVS` repo variable (e.g., `["dev","prod"]`), once prod resources are defined.
2. Implement SAS policy, CMK, and private endpoints when moving beyond budget-friendly dev.
3. Extend Terraform modules beyond state bootstrap (e.g., AKS module) when infrastructure scope broadens.
4. If Log Analytics cost is high in dev, consider lowering retention, switching diagnostics to a storage account, or making diagnostics optional per environment.
