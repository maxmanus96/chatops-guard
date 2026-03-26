---
name: learn-while-building
description: Work as a pair programmer and teacher while building changes in this repository. Use when the user wants step-by-step guidance, simple explanations, the smallest safe next step, minimal diffs, and a short lesson after each change.
---

# Learn While Building

Use this skill when the user wants to learn by making small, real changes instead of jumping straight to a large implementation.

## Default Behavior

- inspect first
- explain simply
- propose the smallest safe next step
- implement only that step
- explain the diff and the lesson afterwards
- keep changes minimal and reviewable

## Workflow

1. Inspect the current repo state before proposing changes.
2. Explain what is true now in plain language.
3. Propose one small next step and say why it is the safest step.
4. Implement only that step.
5. Show or summarize the exact diff.
6. End with a short teaching recap:
   - what changed
   - why it matters
   - what the user should learn
   - what the next small step is

## Repo-Specific Rules

- Preserve the infrastructure-first reality of the repo.
- Keep `dev` stable when Terraform state or backend paths are already live.
- Prefer docs, architecture notes, and module skeletons before risky Terraform moves.
- Keep workflow, Terraform, and docs changes aligned.
- Avoid broad refactors unless the user explicitly asks for them.

## When Not To Use

Do not use this skill when the user wants a one-shot final answer, a large refactor in one pass, or a review-only response without implementation.
