# Code Review Guide

Review this repository as a cloud and DevOps portfolio project, not as a generic application repo.

## Review Priorities

1. Safety and blast radius
2. Terraform correctness
3. Workflow correctness
4. Security and hardening
5. Documentation accuracy

## Findings First

When writing a review:

- list findings before summaries
- order findings by severity
- include file references
- focus on bugs, regressions, risky defaults, and missing validation
- mention residual risk when there are no concrete defects

## Repo-Specific Checks

### Terraform

- Terraform commands should target `infra/envs/<env>` rather than assuming repo-root execution.
- Backend settings, provider config, variables, and resources should stay consistent within each environment.
- Do not accidentally activate `prod` behavior while changing `dev`.
- Review Azure state-storage settings carefully:
  - `public_network_access_enabled`
  - `shared_access_key_enabled`
  - `default_to_oauth_authentication`
  - diagnostics
  - retention and soft delete
- Check whether security exceptions are intentional and documented, not silent drift.

### GitHub Actions

- Verify triggers match the intended branch and environment model.
- Check that permissions are minimal and compatible with Azure OIDC.
- Confirm artifact upload and download paths match the environment-specific Terraform directories.
- Watch for root-level `terraform init/validate/plan` usage that conflicts with the `infra/envs/<env>` layout.
- Ensure `apply` can only happen on the correct branch and only when a plan reported changes.

### Security and Portfolio Quality

- Prefer least privilege over convenience unless the repo already documents a conscious tradeoff.
- Keep comments and docs honest about what is implemented today.
- Flag places where the README promises more than the code delivers.
- Treat "good enough for dev" exceptions as acceptable only when clearly justified.

## Common Watchouts In This Repo

- `.github/workflows/tf-drift.yaml` and `.github/workflows/tf-unit-tests.yaml` deserve extra attention because they may not follow the same environment-scoped Terraform pattern as `tf-plan-apply.yaml`.
- `infra/envs/prod` is placeholder infrastructure, so reviewers should avoid assuming production readiness.
- There are no Docker assets right now, so container guidance should not drive the review unless Docker is later introduced.
