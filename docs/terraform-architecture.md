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
- `infra/modules/aks` now exists as the first reusable module, but it is not wired into a non-bootstrap environment root yet.

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

Design the first non-bootstrap environment root that will eventually call `infra/modules/aks`, without changing the current `infra/envs/dev` backend/bootstrap layout.

That keeps the already-applied `dev` state stable while moving AKS work from module-only scaffolding toward real environment composition.
