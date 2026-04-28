# ChatOps Guard Summariser

Minimal FastAPI service for turning raw ChatOps, AKS, or Azure signals into a
short operator-facing summary.

This is intentionally a rule-based skeleton first. Azure OpenAI, LangChain,
Event Grid subscriptions, queues, and Slack delivery are later slices.

## API

- `GET /healthz`: liveness check for CI, containers, and Kubernetes probes.
- `POST /summarise`: accepts one signal and returns a first-pass summary,
  impact, and next action.

Example request:

```json
{
  "source": "aks",
  "severity": "warning",
  "title": "Readiness probe failures",
  "message": "Pod api-7d9f failed readiness probe 12 times in namespace dev",
  "resource": "pod/api-7d9f"
}
```

## Local Test

```bash
PYTHONPATH=apps/summariser/src pytest apps/summariser/tests
```

## Container Build

From the host setup used for this project:

```bash
flatpak-spawn --host podman build --format docker -t chatops-guard/summariser:local apps/summariser
```

`--format docker` keeps Docker-style image metadata such as `HEALTHCHECK`
available when building with Podman.
