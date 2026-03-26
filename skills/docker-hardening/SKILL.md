---
name: docker-hardening
description: Review and harden Docker assets for the ChatOps Guard cloud and DevOps portfolio project. Use only when Dockerfiles, Compose files, container build steps, or image publishing workflows exist or are being introduced.
---

# Docker Hardening

Use this skill only when the repo contains Docker-related assets or the task explicitly adds them.

## Current Repo Context

- The current repository snapshot does not include Dockerfiles, Compose files, or image-publishing workflows.
- Treat this as a dormant skill for future portfolio expansion, not a prompt to invent container complexity.

## Review Workflow

1. Confirm Docker assets actually exist in the change set.
2. Inspect base images, tags, and package installation steps.
3. Check runtime user, file permissions, entrypoint behavior, exposed ports, and secret handling.
4. Review CI workflows that build or publish images.
5. Return findings first with concrete file references.

## Focus Areas

- pinned base images or digests
- unnecessary root execution
- package-manager cache cleanup and image size hygiene
- secrets passed via build args or copied into layers
- writable filesystem assumptions
- missing health checks or unsafe default commands
- registry publishing without proper branch, tag, or provenance controls

## When Not To Use

If no Docker assets exist, say the skill is not applicable and move the review back to Terraform, workflows, or release docs as appropriate.
