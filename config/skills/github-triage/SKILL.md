---
name: github-triage
description: >-
  Read-only GitHub issue and PR triage skill. Produces evidence-bound reports classifying
  issues by type, severity, and actionability. Identifies duplicates, links related issues,
  and suggests labels and milestone assignments. Does not modify any issues or PRs. Use when
  asked to triage issues, audit the issue tracker, classify bugs, or review open PRs.
  Triggers: 'triage issues', 'triage PRs', 'issue triage', 'audit issues', 'classify bugs',
  'github triage', 'review open issues', 'label issues'.
---

# GitHub Triage — Read-Only Issue & PR Audit

> **READ-ONLY**: This skill never modifies issues, PRs, labels, or milestones. It produces reports only.

## Prerequisites

```bash
gh --version || echo "GitHub CLI not installed"
gh auth status
```

## Phase 1: Data Collection

```bash
# Get open issues
gh issue list --limit 200 --json number,title,body,labels,createdAt,author,comments --state open > /tmp/issues.json

# Get open PRs
gh pr list --limit 100 --json number,title,body,labels,createdAt,author,reviewRequests,isDraft --state open > /tmp/prs.json

# Repository context
gh repo view --json name,description,defaultBranchRef,openIssues,openPullRequests
```

## Phase 2: Issue Classification

For each issue, classify:

| Dimension | Options |
|---|---|
| **Type** | Bug, Feature Request, Enhancement, Question, Documentation, Chore, Duplicate |
| **Severity** | Critical (blocks usage), High (major pain), Medium (notable friction), Low (nice to have) |
| **Actionability** | Ready (clear enough to implement), Needs Info (missing details), Blocked (waiting on something), Stale (no activity >90 days) |
| **Duplicates** | List issue numbers that describe the same problem |

## Phase 3: PR Review

For each open PR:
- **Status**: Ready to merge, Needs changes, Blocked on CI, Draft, Stale
- **Risk**: Low (small, isolated), Medium (cross-module), High (large, breaking)
- **Missing**: Tests, documentation, changelog entry

## Phase 4: Report

Write `TRIAGE_REPORT.md`:

```markdown
# GitHub Triage Report
**Date**: ...
**Repo**: ...
**Open Issues**: N | **Open PRs**: M

## Issue Summary
| # | Title | Type | Severity | Actionability | Notes |
|---|---|---|---|---|---|

## Duplicate Clusters
- Issues #X, #Y, #Z are all the same problem: [description]

## High-Priority Issues (Critical + High Severity, Ready)
[list]

## Stale Issues (no activity >90 days)
[list with suggested action: close or re-triage]

## PR Status
| # | Title | Status | Risk | Missing |
|---|---|---|---|---|

## Recommended Immediate Actions
1. [action]
2. [action]
```

## Execution Handoff

When transitioning triaged action items into implementation:
- **Small Bugs / Quick Fixes**: Trigger [`/flashplan`](../flashplan/SKILL.md) &rarr; `.workflow/plans/<SEQ>-YYYYMMDD-<kebab-case>.md`.
- **Feature Requests / Specs**: Explore intent and design via [`/brainstorm`](../brainstorm/SKILL.md).
- **Medium Multi-File Issues**: Plan via [`/superplan`](../superplan/SKILL.md).
- **Full PR Delivery**: Launch [`work-with-pr`](../work-with-pr/SKILL.md) for isolated worktree setup, planning, test verification, and PR creation.
- **Autonomous Execution**: Execute any plan with [`/hyperexecution`](../hyperexecution/SKILL.md) under [`orchestrate`](../orchestrate/SKILL.md) discipline.
