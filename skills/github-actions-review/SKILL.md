---
name: github-actions-review
description: Review GitHub Actions workflows for the ChatOps Guard cloud and DevOps portfolio project. Use when evaluating workflow triggers, permissions, Terraform path scoping, Azure OIDC usage, plan and apply safety, or CI drift against the repo layout.
---

# GitHub Actions Review

Use this skill when the task is to review or harden workflows in `.github/workflows/`.

## Repo Context

- The most important workflow is `tf-plan-apply.yaml`.
- Terraform commands are supposed to operate from `infra/envs/<env>`.
- Azure authentication is done through GitHub OIDC.
- This repo currently has more infrastructure automation than application delivery logic.

## Review Workflow

1. Read the touched workflow and identify every step that calls Terraform or cloud auth.
2. Verify triggers, concurrency, and branch conditions match the intended deployment model.
3. Inspect permissions for least privilege.
4. Confirm path handling, matrix handling, artifacts, and outputs are consistent end to end.
5. Check that apply or destructive behavior cannot run from the wrong event or branch.
6. Return findings first with concrete file references.

## Focus Areas

- repo-root Terraform execution versus `infra/envs/<env>` execution
- mismatched artifact names or paths between plan and apply jobs
- missing or excessive permissions
- weak branch guards around `apply`
- OIDC configuration drift
- reliance on mutable actions or unpinned tooling where that meaningfully increases risk
- summary or PR-comment steps that can fail unexpectedly

## Repo-Specific Watchouts

- `tf-drift.yaml` and `tf-unit-tests.yaml` should be checked closely against the current environment-scoped Terraform layout.
- Workflow changes should not imply that production is active unless the repo explicitly enables it.
- If a workflow changes security posture, call out whether `README.md` or `plan.md` now needs updating.
