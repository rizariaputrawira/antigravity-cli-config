---
name: get-unpublished-changes
description: >-
  Surfaces all changes that exist locally or on a branch but have not yet been published
  (released, merged to the default branch, or tagged). Shows the delta between current state
  and the last release or merge point: uncommitted changes, unpushed commits, merged-but-unreleased
  PRs, and unreleased changelog entries. Use when asked 'what has changed since last release',
  'what's unpublished', 'what would be in the next release', 'get unpublished changes',
  'show unreleased work'. Triggers: 'unpublished changes', 'unreleased changes', 'what changed',
  'since last release', 'get-unpublished-changes'.
---

# Get Unpublished Changes

Surfaces all work that exists but has not been released/published. Produces a structured report.

## Phase 1: Locate the Baseline

Find the last release point:

```bash
# Last tag:
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
echo "Last tag: $LAST_TAG"

# Last release commit (if using CHANGELOG):
grep -n "^## \[" CHANGELOG.md 2>/dev/null | head -5

# Default branch HEAD:
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | grep 'HEAD branch' | awk '{print $NF}' || echo "main")
git log --oneline "$DEFAULT_BRANCH" -5
```

## Phase 2: Uncommitted Changes

```bash
git status --short
git diff --stat HEAD
git stash list
```

## Phase 3: Unpushed Commits

```bash
# Commits on current branch not on remote:
git log --oneline @{u}..HEAD 2>/dev/null || git log --oneline origin/$(git branch --show-current)..HEAD 2>/dev/null

# Commits ahead of default branch:
git log --oneline "origin/$DEFAULT_BRANCH..HEAD"
```

## Phase 4: Commits Since Last Tag

```bash
if [ "$LAST_TAG" != "none" ]; then
  git log --oneline "$LAST_TAG..HEAD"
  git diff --stat "$LAST_TAG..HEAD"
fi
```

## Phase 5: Unreleased CHANGELOG Entries

```bash
# Find entries between [Unreleased] section and last version:
awk '/^## \[Unreleased\]/,/^## \[[0-9]/' CHANGELOG.md 2>/dev/null | head -50
```

## Phase 6: Open PRs Targeting Default Branch

```bash
gh pr list --base "$DEFAULT_BRANCH" --state open --json number,title,author,createdAt 2>/dev/null
```

## Output Format

```
## Unpublished Changes Report
Generated: [date]
Baseline: [last tag or commit]

### Uncommitted Changes
[git status output]

### Unpushed Commits ([N] commits)
[git log output]

### Commits Since Last Release
[git log since last tag]

### Unreleased CHANGELOG Entries
[CHANGELOG [Unreleased] section]

### Open PRs
[PR list]

### Summary
- Uncommitted files: N
- Unpushed commits: M
- Commits since last tag: P
- Open PRs: Q
```
