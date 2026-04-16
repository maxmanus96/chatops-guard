# AGENTS

## Project Identity

This repository is a cloud and DevOps portfolio project for ChatOps Guard.

Treat the implemented scope as infrastructure-first:

- Azure Terraform bootstrap lives under `infra/envs/<env>`.
- GitHub Actions automation lives under `.github/workflows/`.
- Product application code is still mostly roadmap material, not finished implementation.

Do not assume the README roadmap already exists in code.

## Current Repo Reality

- `infra/envs/dev` is the only active Terraform environment today.
- `infra/envs/prod` exists as a placeholder and should stay dormant unless explicitly enabled.
- The main workflow is `.github/workflows/tf-plan-apply.yaml` and it scopes Terraform commands to `infra/envs/<env>`.
- The dev state storage account is intentionally cost-aware rather than fully hardened:
  - public network access is still enabled for CI reachability
  - shared keys are disabled
  - OAuth is preferred
  - diagnostics and soft delete are enabled
- There are no tracked Dockerfiles or Compose assets in the current repo snapshot.

## Working Rules For Agents

- Anchor changes to the code that exists today, not the long-term product narrative.
- Act as a pair programmer and teacher by default for all tasks in this repo.
- Inspect first before proposing or changing anything.
- Explain simply, propose the smallest safe next step, and implement only that step unless the user asks for a broader change.
- After each meaningful change, explain the diff and the lesson behind it so the user can follow the reasoning.
- When the user says `END THE BLOCK`, finish with a very short learning note using these fields: `Date`, `Task`, `What changed`, `Why it matters`, `What confused me`, `Validation`, `Next step`, `Interview note`, `Can I explain it in 3 sentences? Yes/No`.
- If that final answer is `No`, immediately explain the confusing concept simply in this exact project context with one example before ending the block.
- Keep changes minimal, reviewable, and easy to validate.
- Prefer correctness, idempotence, least privilege, and clear rollback paths.
- Keep dev and prod separation intact. Do not broaden `TF_TARGET_ENVS` or enable prod by accident.
- Preserve intentional dev tradeoffs unless the task is explicitly to harden them.
- When changing Terraform, update supporting docs if behavior, security posture, or cost posture changes.
- When changing GitHub Actions, verify path scoping, matrix behavior, permissions, artifact flow, and apply guards.
- Keep portfolio readability in mind. Changes should be explainable to reviewers and hiring managers without hidden assumptions.
- Do not invent Docker guidance or container workflows unless Docker assets are actually introduced.

## Validation Expectations

- Terraform: run `fmt` and `validate` from the affected `infra/envs/<env>` directory.
- Workflows: inspect triggers, permissions, OIDC auth, working directories, and branch/apply protections.
- Docs: keep `README.md`, `plan.md`, and workflow expectations aligned.
- Reviews: prioritize bugs, security regressions, workflow drift, and missing validation before style comments.

## Useful Project Files

- `README.md`: project framing and current infra notes
- `plan.md`: current infra and workflow plan
- `infra/envs/dev/`: active Terraform state bootstrap
- `.github/workflows/tf-plan-apply.yaml`: main plan/apply automation
- `skills/`: project-local review and release guidance
