# ChatOps Guard Wiki

This Wiki page is intentionally small. Keep the repository docs as the source
of truth because they are reviewed through pull requests and CI.

## Start Here

- Project overview: `README.md`
- Infra and workflow plan: `plan.md`
- Current backlog: `docs/TODO.md`
- Terraform architecture: `docs/terraform-architecture.md`
- Azure OIDC least privilege notes: `docs/azure-oidc-least-privilege.md`

## Current Project Reality

ChatOps Guard is currently infrastructure-first. The active Terraform work is
focused on Azure bootstrap resources, GitHub Actions automation, and the staged
`dev-platform` AKS path. Product application code is still mostly roadmap
material.

## Local Validation

Run the repo-backed local validation helper before pushing workflow or
Terraform changes:

```bash
scripts/local_validate.sh
```

From the Flatpak/toolbox host setup used in this project:

```bash
flatpak-spawn --host toolbox run -c dev bash -lc 'cd /var/home/maxmanus/Dokumente/Coding/chatops-guard && scripts/local_validate.sh'
```

This mirrors the low-cost CI checks where practical: YAML parsing, actionlint,
Terraform format/init/validate, and Checkov scans for the active Terraform
roots.

## Wiki Policy

Do not let the Wiki become a second source of truth. Use it as a lightweight
navigation page that points back to reviewed repo documentation.
