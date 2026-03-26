---
name: release-docs
description: Write release notes and release-facing documentation for the ChatOps Guard cloud and DevOps portfolio project. Use when preparing changelogs, GitHub release notes, milestone summaries, or portfolio-ready documentation for infrastructure and CI milestones.
---

# Release Docs

Use this skill when the task is to write release notes, changelog entries, milestone summaries, or portfolio-facing documentation.

## Repo Context

- This project currently showcases infrastructure bootstrap and CI automation more than finished application features.
- Release messaging should be honest about that maturity level.
- A good release note for this repo highlights Terraform environment structure, Azure state hardening decisions, GitHub Actions automation, and known next steps.

## Writing Workflow

1. Identify what actually changed in Terraform, workflows, scripts, or docs.
2. Separate shipped behavior from planned behavior.
3. Explain security, reliability, or automation improvements in plain language.
4. Call out known limits and deliberate tradeoffs without hiding them.
5. Produce concise release material suited for GitHub and portfolio presentation.

## Good Content For This Repo

- new Terraform environments or modules
- workflow automation changes
- security hardening improvements
- documentation cleanup that makes the project easier to evaluate
- honest next steps for production readiness

## Avoid

- implying that unfinished app features are already implemented
- overselling placeholder `prod` support
- vague release notes that do not mention concrete infrastructure or workflow changes
- burying important tradeoffs such as dev-only public access or deferred private endpoints
