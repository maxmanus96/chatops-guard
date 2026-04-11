# Terraform Architecture

Status: proposed
Date: 2026-03-22
Related issue: #12

## Why this exists

The repository already has a live `dev` Terraform layout under `infra/envs/dev` and that environment has already been planned/applied. That means the safest path is to document the target architecture first and avoid moving the live backend/state layout until a controlled migration is planned.

## Current state

- `infra/envs/dev` is the active Terraform root.
- `infra/envs/dev` currently manages remote-state bootstrap resources.
- `infra/envs/prod` exists as a placeholder.
- `infra/modules/` now holds the first reusable module at `infra/modules/aks`, tracked in issue `#1` and PR `#40`.
- The AKS module currently exposes a small but explicit baseline for monitoring, API access restrictions, upgrade channel, and Azure CNI Overlay + Cilium networking.

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

## AKS Dev Networking Note

For the first real `dev` AKS cluster, prefer this network shape:

- use a dedicated node subnet such as `snet-aks-nodes` instead of sharing a general-purpose subnet
- start with `/24` as the node subnet size to leave headroom for node growth, upgrade surge, and internal load balancer IP use
- keep `outbound_type = "loadBalancer"` for the first demo cluster because it is the cheapest and simplest egress path
- revisit NAT Gateway later if the project needs a more controlled or more stable shared outbound IP posture

Why this fits the current repo:

- Azure CNI Overlay means node subnet sizing is mostly about node IPs, not pod IPs
- the repo is still in a demo-safe, cost-aware stage
- private cluster and tighter egress controls are better introduced after there is a VNet-connected admin or runner path

### Concrete Dev Example

Use this as the first real `dev` shape once AKS is actually wired into a non-bootstrap environment root:

```text
vnet-chatops-guard-dev      10.30.0.0/16
└── snet-aks-nodes          10.30.0.0/24
    ├── AKS node-1          10.30.0.4
    ├── AKS node-2          10.30.0.5
    └── AKS internal LB IPs 10.30.0.x

AKS API server:
- public endpoint for the first demo cluster
- restricted with api_server_authorized_ip_ranges

AKS pod networking:
- Azure CNI Overlay
- pod IPs come from the overlay address space, not from 10.30.0.0/24

Cluster egress:
- outbound_type = "loadBalancer"
- AKS manages the standard load balancer egress path
```

Why this concrete example is safe:

- `/24` is generous enough for a small dev cluster, upgrade surge, and internal load balancer IPs without being excessive for a portfolio demo
- a dedicated node subnet avoids mixing AKS nodes with unrelated resources
- `loadBalancer` keeps cost and operational complexity lower than introducing NAT Gateway immediately

### Alternatives Considered

- smaller node subnet such as `/26`:
  cheaper in IP space, but easier to outgrow during upgrades or later node-pool expansion
- larger node subnet such as `/23`:
  more headroom, but unnecessary for the current demo-sized target
- `managedNATGateway` egress:
  stronger and more stable outbound IP control, but adds recurring cost and another Azure network dependency
- `userAssignedNATGateway` or `userDefinedRouting`:
  more control, but better saved for a later hardening phase when the VNet and firewall story are real

## What not to do yet

- Do not rename `infra/envs/dev`.
- Do not change the backend key or storage layout casually.
- Do not enable `prod` in CI until production roots and resources are real.
- Do not mix bootstrap-only resources and future AKS/application resources into one growing root forever.

## First safe next step

Continue evolving the first reusable module under `infra/modules/aks` without changing the current `dev` backend/bootstrap layout.

That gives the project a forward path toward reusable infrastructure while keeping the already-applied `dev` state stable.
