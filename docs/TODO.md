# TODO

Source: GitHub issues plus merged infra/CI work refreshed on 2026-04-16.

This file is a grouped planning view of the current backlog after the recent bootstrap/state recovery work. Some older issues are now delivered in merged PRs and are shown here as completion or cleanup notes rather than as active implementation tasks.

## Infrastructure

### Terraform architecture and bootstrap cleanup
- Priority: P0
- Short summary: Keep the recovered `dev` bootstrap root stable, close stale follow-up issues, and keep the backlog aligned with the repo's now-working Terraform state.
- Estimated effort: 0.5-1 day
- Dependencies: one clean manual drift run on `main`, issue-triage pass on stale umbrella items
- Tasks:
  - [x] #14 INF-01 · Remote state RG & Storage
  - [x] #46 stale drift issue closed after the recovered `dev` root returned to clean drift behavior
  - [ ] Close issue #43 now that `tf-drift` is working again
  - [ ] Reconcile or close #5 Draft terraform folder and do initial commit if the current repo already satisfies it
  - [ ] Keep #13 Seed backlog aligned with the infrastructure child issues that remain open

### AKS and platform services baseline
- Priority: P1
- Short summary: Keep bootstrap separate from platform composition while turning the merged AKS module into a staged environment-root path.
- Estimated effort: 3-5 days
- Dependencies: final AKS demo-risk decision, target Azure region and sizing, environment promotion plan
- Tasks:
  - [x] #1 Define minimal AKS module
  - [x] #15 INF-02 · Terraform AKS module (dev) closed by PR #40
  - [x] #50 INF-06 · First dev-platform Terraform root for staged AKS rollout
  - [x] Scaffold `infra/envs/dev-platform` as the first non-bootstrap environment root for AKS composition
  - [x] Add `enable_aks = false` so the first safe apply can create only the platform resource group
  - [x] Apply `infra/envs/dev-platform` once to create `rg-chatops-guard-platform-dev` without creating AKS
  - [x] Add `infra/modules/network` and apply the minimal dev VNet/subnet foundation
  - [x] Replace the raw subnet input with `module.network.aks_node_subnet_id`
  - [x] Replace the raw Log Analytics workspace ID input with a workspace lookup by name and resource group
  - [x] Add `terraform.tfvars.example` so the safe-first-apply path and first AKS-enable path are both visible
  - [x] Produce the first real `enable_aks = true` AKS plan successfully
  - [x] Keep the first AKS rollout local-first with an untracked `infra/envs/dev-platform/terraform.tfvars`
  - [x] Set `api_server_authorized_ip_ranges` locally before the first apply; `enable_aks = true` now requires it
  - [x] Keep `local_account_disabled = false` for the first demo cluster until managed AAD integration exists
  - [x] Prove the first local `enable_aks = true` apply from `infra/envs/dev-platform`
  - [x] Add `dev-platform` GitHub validation/plan-apply follow-up issue `#53`
  - [ ] #52 INF-07 · AKS managed Entra ID integration and disable local accounts
  - [ ] Keep AKS design decisions explicit: egress, admin access path, private-cluster timing
  - [ ] #16 INF-03 · Event Grid + Topic
  - [ ] #17 INF-04 · Azure OpenAI (private endpoint)
  - [ ] #18 INF-05 · Key Vault + Workload Identity

### Cluster policy and runtime guardrails
- Priority: P1
- Short summary: Add the first platform-level policy control needed before application workloads become meaningful.
- Estimated effort: 1-2 days
- Dependencies: AKS baseline, workload identity design, container security standards
- Tasks:
  - [ ] #29 SEC-02 · OPA policy for privileged ctrs

## CI/CD

### CI baseline, image pipeline, and scan gates
- Priority: P0
- Short summary: Use the now-working Terraform workflow baseline as the starting point for the next CI/CD slices instead of spending more time on bootstrap/workflow repair.
- Estimated effort: 2-4 days
- Dependencies: issue hygiene cleanup after the recent merges, image naming/versioning strategy
- Tasks:
  - [ ] #2 Add Ci&CD to the repo
  - [ ] Close issue #43 now that the repaired `tf-drift` workflow is stable again
  - [ ] #53 CI-04 · Add dev-platform to Terraform GitHub validation and plan/apply
  - [ ] #28 SEC-01 · Trivy image + IaC scan gate
  - [ ] #30 SEC-03 · SBOM generation & upload
  - [ ] #31 CI-01 · Build & push images to ACR
  - [ ] #8 Secure ACR Images when they are available

### Deployment and promotion workflows
- Priority: P1
- Short summary: Add environment deployment flow after image build is stable, while cleaning up duplicate or overlapping CI issues.
- Estimated effort: 2-4 days
- Dependencies: Helm charts, target dev environment, production promotion policy
- Tasks:
  - [ ] #32 CI-02 · Helm deploy to dev on merge
  - [ ] #33 CI-02 · Helm deploy to dev on merge
  - [ ] Verify whether #32 and #33 are intentional separate tasks or a duplicate that should be merged
  - [ ] #34 CI-03 · Manual prod promotion job

### GitHub workflow automation
- Priority: P2
- Short summary: Automate issue lifecycle updates so project tracking stays in sync with merged work.
- Estimated effort: 0.5-1 day
- Dependencies: agreement on GitHub Projects workflow and issue state transitions
- Tasks:
  - [ ] #38 AUT-01 · Built-in rule: Issue closed -> Done
  - [ ] #39 AUT-02 · Action: PR merged moves linked issue

## Application

### Chat ingress and interaction layer
- Priority: P1
- Short summary: Establish the first user-facing bot surface and authentication flow for ChatOps interactions.
- Estimated effort: 3-5 days
- Dependencies: runtime choice, Slack app setup, OAuth callback design
- Tasks:
  - [ ] #22 BOT-01 · Go Slack bot skeleton
  - [ ] #23 BOT-02 · Interactive buttons & OAuth

### Summarization and event-processing path
- Priority: P1
- Short summary: Build the first end-to-end backend flow from event ingestion through summarization.
- Estimated effort: 4-7 days
- Dependencies: Event Grid and queue infrastructure, Azure OpenAI access, service runtime decisions
- Tasks:
  - [ ] #24 SUM-01 · Python FastAPI summariser
  - [ ] #25 SUM-02 · LangChain prompt w/ Azure OpenAI
  - [ ] #27 API-01 · Event Grid -> Queue -> Summariser

### Action execution surface
- Priority: P2
- Short summary: Add the initial controlled execution path for run-book or operational commands.
- Estimated effort: 2-3 days
- Dependencies: cluster baseline, security policy guardrails, bot interaction design
- Tasks:
  - [ ] #26 ACT-01 · Run-book runner pod

## Docs

### Architecture and quick-start documentation
- Priority: P1
- Short summary: Add the missing docs needed for reviewers to understand the system shape and try it locally.
- Estimated effort: 1-2 days
- Dependencies: stable architecture decisions, local dev story, demo path
- Tasks:
  - [x] #35 DOC-01 · Mermaid architecture diagram
  - [ ] #36 DOC-02 · Quick-start with KinD mocks

### Contribution and backlog documentation
- Priority: P2
- Short summary: Document ongoing work and open-source activity clearly enough that the portfolio story stays maintainable.
- Estimated effort: 0.5-1 day
- Dependencies: preferred contribution-tracking format, backlog hygiene decisions
- Tasks:
  - [ ] #37 DOC-03 · OSS-CONTRIBUTIONS.md tracker
  - [ ] Keep #13 Seed backlog consistent with this grouped TODO view and the current issue structure

## Monitoring

### Metrics, alerting, and dashboards
- Priority: P1
- Short summary: Add the first useful observability stack for platform health, logs, and operator visibility.
- Estimated effort: 3-5 days
- Dependencies: AKS baseline, Helm deployment path, alert destinations, dashboard ownership
- Tasks:
  - [ ] #19 OBS-01 · Helm Prometheus + Alertmanager
  - [ ] #20 OBS-02 · Loki + Grafana dashboards

### Event-driven autoscaling
- Priority: P2
- Short summary: Introduce autoscaling once the event pipeline and workloads are stable enough to benefit from it.
- Estimated effort: 1-2 days
- Dependencies: Event Grid topic, queue consumer path, AKS and KEDA readiness
- Tasks:
  - [ ] #21 OBS-03 · KEDA ScaledObject on Event Grid
