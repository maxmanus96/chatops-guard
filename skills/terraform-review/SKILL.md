---
name: terraform-review
description: Review Terraform changes for the ChatOps Guard cloud and DevOps portfolio project. Use when evaluating infra/envs/*, Azure backend and state changes, Terraform workflow alignment, or security and cost tradeoffs in the current infrastructure bootstrap.
---

# Terraform Review

Use this skill when the task is to review, validate, or critique Terraform in this repository.

## Repo Context

- Active Terraform lives under `infra/envs/dev`.
- `infra/envs/prod` exists but is mostly placeholder material.
- The current Terraform footprint is remote-state bootstrap on Azure, not full application infrastructure.
- CI expects Terraform work to run from `infra/envs/<env>`.

## Review Workflow

1. Identify touched files under `infra/` and any workflow files that invoke Terraform.
2. Check whether commands are scoped to the correct environment directory.
3. Review backend, provider, variable, and resource consistency inside the same environment.
4. Evaluate security and cost tradeoffs, especially where dev intentionally accepts weaker controls.
5. Cross-check docs when the change alters behavior or posture.
6. Return findings first, ordered by severity, with file references.

## Focus Areas

- backend state key, storage account, container, and resource-group mismatches
- wrong `-chdir` or working-directory assumptions
- accidental `prod` activation or environment leakage
- unsafe or undocumented changes to:
  - `public_network_access_enabled`
  - `shared_access_key_enabled`
  - `default_to_oauth_authentication`
  - diagnostics and retention
  - blob and container delete retention
- security-scan skips that are no longer justified
- docs drift between Terraform code, `README.md`, and `plan.md`

## Output Standard

- Findings first
- Highest severity first
- File references for each finding
- Call out missing validation if `fmt`, `validate`, or security scanning was not run
