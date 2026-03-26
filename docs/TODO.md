# TODO

Source: 32 open GitHub issues in `maxmanus96/chatops-guard` as retrieved via GitHub MCP on 2026-03-22.

This file is a grouped planning view of the current open issues. Some open issues are umbrella or backlog-management issues, so they are represented as planning or cleanup tasks where appropriate rather than duplicated as standalone implementation work.

## Infrastructure

### Terraform architecture and bootstrap cleanup
- Priority: P0
- Short summary: Finish the Terraform foundation, reconcile the open bootstrap issues with the repo's current state, and keep the backlog epic aligned with the actual infrastructure scope.
- Estimated effort: 1-2 days
- Dependencies: agreement on Terraform folder architecture, issue-triage pass on stale umbrella items
- Tasks:
  - [ ] #12 Decide on architecture for terraform
  - [ ] #14 INF-01 · Remote state RG & Storage
  - [ ] Reconcile or close #5 Draft terraform folder and do initial commit if the current repo already satisfies it
  - [ ] Keep #13 Seed backlog aligned with the infrastructure child issues that remain open

### AKS and platform services baseline
- Priority: P1
- Short summary: Move from state-bootstrap-only Terraform toward the first real platform components needed to host the application.
- Estimated effort: 4-7 days
- Dependencies: final Terraform module structure, target Azure region and sizing, environment promotion plan
- Tasks:
  - [ ] #1 Define minimal AKS module
  - [ ] #15 INF-02 · Terraform AKS module (dev)
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
- Short summary: Turn the current Terraform-focused workflows into a full delivery baseline for build, scan, publish, and registry security.
- Estimated effort: 3-5 days
- Dependencies: container build inputs, ACR design, app image naming/versioning strategy
- Tasks:
  - [ ] #2 Add Ci&CD to the repo
  - [ ] #31 CI-01 · Build & push images to ACR
  - [ ] #8 Secure ACR Images when they are available
  - [ ] #28 SEC-01 · Trivy image + IaC scan gate
  - [ ] #30 SEC-03 · SBOM generation & upload

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
  - [ ] #35 DOC-01 · Mermaid architecture diagram
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
