# ChatOps Guard

A security and monitoring tool for ChatOps environments that helps protect and control chat-based operations.

## Overview

ChatOps Guard is designed to provide security, monitoring, and access control for ChatOps (Chat Operations) workflows. It helps organizations safely implement chat-based automation by providing guardrails and security measures for bot interactions and automated processes.

## Architecture

```mermaid
graph TB
    subgraph "Chat Platforms"
        A[Slack] 
        B[Microsoft Teams]
        C[Discord]
        D[Other Chat Platforms]
    end
    
    subgraph "ChatOps Guard"
        E[Command Parser]
        F[Access Control]
        G[Rate Limiter]
        H[Command Filter]
        I[Audit Logger]
        J[Security Validator]
    end
    
    subgraph "Backend Systems"
        K[CI/CD Pipelines]
        L[Cloud Infrastructure]
        M[Databases]
        N[Monitoring Tools]
        O[Deployment Systems]
    end
    
    subgraph "Storage & Monitoring"
        P[Audit Database]
        Q[Dashboard]
        R[Alerts & Notifications]
    end
    
    A --> E
    B --> E
    C --> E
    D --> E
    
    E --> F
    F --> G
    G --> H
    H --> J
    J --> I
    
    I --> P
    I --> Q
    I --> R
    
    J --> K
    J --> L
    J --> M
    J --> N
    J --> O
    
    style E fill:#e1f5fe
    style F fill:#fff3e0
    style G fill:#fff3e0
    style H fill:#fff3e0
    style I fill:#e8f5e8
    style J fill:#fff3e0
```

**Flow Description:**
1. **Input**: Users send commands through various chat platforms
2. **Parsing**: Commands are parsed and structured by ChatOps Guard
3. **Security Pipeline**: Commands pass through multiple security layers:
   - Access control validates user permissions
   - Rate limiting prevents abuse
   - Command filtering validates syntax and content
   - Security validator performs final checks
4. **Execution**: Approved commands are forwarded to backend systems
5. **Logging**: All activities are logged for audit and monitoring
6. **Monitoring**: Dashboard and alerts provide real-time visibility

## Features

- **Access Control**: Manage who can execute specific ChatOps commands
- **Audit Logging**: Track and log all ChatOps activities for compliance and security
- **Command Filtering**: Filter and validate commands before execution
- **Rate Limiting**: Prevent abuse through configurable rate limits
- **Integration Ready**: Easy integration with popular chat platforms and CI/CD tools

## Installation

```bash
# Installation instructions will be added as the project develops
# Stay tuned for release packages and installation guides
```

## Usage

```bash
# Usage examples will be provided once the core functionality is implemented
# Check back for comprehensive documentation and examples
```

## Configuration

Configuration details and examples will be documented as features are implemented.

## Infrastructure & Security Notes

- Terraform lives under `infra/envs/<env>` and currently manages only the `dev` bootstrap/state resources. The live `dev` root is now state-aligned again and `terraform plan/apply` succeeds from CI.
- The active `dev` bootstrap root currently manages:
  - the state resource group
  - the state storage account and `tfstate` container
  - the Log Analytics workspace used for storage diagnostics
  - the blob-service diagnostic setting that sends storage logs/metrics to Log Analytics
- `infra/modules/aks` now exists as the first reusable platform module, and `infra/envs/dev-platform` is the first thin non-bootstrap root that composes it. That root now has its own backend/state, has safely applied `rg-chatops-guard-platform-dev` plus a minimal VNet/subnet foundation, and can produce a real `enable_aks = true` plan while AKS still stays explicitly gated by default. When AKS is enabled there, `api_server_authorized_ip_ranges` must also be set so the first demo cluster does not leave its public API open unintentionally.
- The first AKS rollout path was intentionally local-first to prove the cluster create with an untracked `infra/envs/dev-platform/terraform.tfvars` and a local `/32` admin IP.
- GitHub Terraform workflows now target both `dev` and `dev-platform` by default, so future AKS Terraform changes can be planned/applied from Actions as well.
- The current cost-aware demo default for AKS nodes is `Standard_D2as_v5`, not `Standard_D2_v2`. That is the current best-ROI middle ground: materially cheaper than Dv2, more modern, and less memory-constrained than the ultra-cheap `A2_v2` candidate.
- B-series was not chosen for the demo default because Microsoft documents B-series VMs as unsupported for AKS system node pools.
- The first demo AKS cluster originally kept local accounts enabled because disabling them on Kubernetes 1.25+ requires managed Entra ID integration. Issue `#52` now wires that managed Entra path into Terraform so the next AKS-enabled apply can flip `local_account_disabled` on deliberately instead of by demo shortcut.
- For issue `#52`, the chosen access model is a dedicated Entra admin group, not an individual user object ID. That keeps AKS admin access transferable, reviewable, and easier to explain than binding cluster admin access to one person.
- Issue `#52` keeps `azure_rbac_enabled = false` in the first managed Entra slice. That is intentional: the smallest useful change is authentication hardening plus disabling local accounts; Azure RBAC role design is a separate authorization rollout.
- Production definitions exist but remain dormant until explicitly enabled via GitHub Actions `TF_TARGET_ENVS`.
- GitHub Actions workflow `.github/workflows/tf-plan-apply.yaml` uses a matrix to run `plan/apply` per environment while scoping Terraform commands to `infra/envs/<env>` so prod is untouched unless opted in.
- Security posture for the dev state storage account balances CI access with cost:
  - Public network access stays enabled so GitHub Actions can reach the backend; blob/anonymous access is disabled and shared keys are off.
  - Azure AD auth is preferred end-to-end for the storage account, and the Terraform provider is configured to use Azure AD for storage data-plane operations.
  - Diagnostics go to a Log Analytics workspace with 30-day retention, using the blob service resource scope that Azure Monitor actually supports for storage read/write/delete logs.
  - Soft delete is enabled on blob/container operations (7 days), and blob versioning remains enabled to keep tfstate recovery practical with modest dev cost impact.
  - Checkov skips in dev (documented inline in `infra/envs/dev/main.tf`) due to budget/complexity:
    - CKV2_AZURE_1 (CMK), CKV_AZURE_206 (GRS replication), CKV_AZURE_59 (public network), CKV2_AZURE_33 (private endpoint).
    - CKV_AZURE_33 (queue logging), CKV2_AZURE_21 (blob read logging).
- Budget-conscious items still pending for dev (tracked in [plan.md](plan.md)):
  - Geo-redundant replication (CKV_AZURE_206) intentionally left as LRS to minimize cost.
  - Customer-managed keys (CKV2_AZURE_1), SAS expiration policy (CKV2_AZURE_41), and private endpoints (CKV2_AZURE_33) are deferred until prod hardening.

## Contributing

We welcome contributions to ChatOps Guard! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

Development setup instructions will be added as the project structure is established.

## Security

If you discover a security vulnerability, please report it responsibly by emailing the maintainer rather than opening a public issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Roadmap

- [ ] Core security framework
- [ ] Chat platform integrations
- [ ] Command validation system
- [ ] Audit logging implementation
- [ ] Web dashboard for monitoring
- [ ] Plugin system for extensibility

## Author

**Hüseyin Hürkan Karaman** - [@maxmanus96](https://github.com/maxmanus96)

---

⚠️ **Note**: This project is in early development. Features and documentation will be expanded as development progresses.
