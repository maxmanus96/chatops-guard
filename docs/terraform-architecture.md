# Terraform Architecture

Status: proposed
Date: 2026-03-22
Related issue: #12

## Why this exists

The repository already has a live `dev` Terraform layout under `infra/envs/dev` and that environment has already been planned/applied. That means the safest path is to document the target architecture first and avoid moving the live backend/state layout until a controlled migration is planned.

## Current state

- `infra/envs/dev` is the active Terraform root.
- `infra/envs/dev` currently manages remote-state bootstrap resources and now successfully plans/applies again after the bootstrap resources were imported into state and the storage diagnostics scope was corrected.
- `infra/envs/prod` exists as a placeholder.
- `infra/modules/aks` now exists as the first reusable module, delivered by issue `#1` and PR `#40`.
- `infra/envs/dev-platform` now exists as the first thin non-bootstrap environment root that composes the AKS module without changing the live bootstrap root.
- That root now has its own backend/state and has been safely applied once to create only the platform resource group while `enable_aks = false` keeps cluster creation off by default.

## Decision

Use a layered Terraform structure:

```text
infra/
  bootstrap/
    state/
      dev/
      prod/
  modules/
    aks/
    acr/
    event-grid/
    key-vault/
    openai/
    monitoring/
  envs/
    dev/
    prod/
```

### Meaning of each layer

- `infra/bootstrap/state/<env>`:
  only backend/bootstrap resources such as state resource groups, storage accounts, containers, and related diagnostics
- `infra/modules/*`:
  reusable building blocks with clear inputs and outputs
- `infra/envs/<env>`:
  thin environment roots that compose modules for each environment

## Safety rule

Because `dev` is already live, do not rename or move the current `infra/envs/dev` backend/state root yet.

Until a migration is planned, treat the current `infra/envs/dev` directory as the active bootstrap root.

## Migration approach

1. Document the target architecture first.
2. Add reusable modules without changing the live backend path.
3. Introduce thin environment roots for platform resources step by step.
4. Only move bootstrap/state code later if there is an explicit backend/state migration plan.

## What not to do yet

- Do not rename `infra/envs/dev`.
- Do not change the backend key or storage layout casually.
- Do not enable `prod` in CI until production roots and resources are real.
- Do not mix bootstrap-only resources and future AKS/application resources into one growing root forever.

## Current safe next step

That step is now done: `infra/envs/dev-platform` is the first thin non-bootstrap environment root that composes the AKS module while leaving `infra/envs/dev` bootstrap-only.

Why the name is explicit right now:

- `infra/envs/dev` is still the live bootstrap root
- `infra/envs/dev-platform` makes the platform boundary visible until there is an explicit bootstrap migration plan

## Next safe step after that scaffold

Keep the first real `dev-platform` rollout on explicit injected inputs for the node-subnet ID and Log Analytics workspace ID. The repo now documents that contract in `infra/envs/dev-platform/terraform.tfvars.example`.

Then fill in the real values before any first `enable_aks = true` AKS plan/apply.

That keeps the already-applied `dev` state stable while moving AKS work from module-only scaffolding toward real environment composition.
