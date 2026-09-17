---
name: work-with-pr
description: >-
  Full PR lifecycle skill. Implements a task in a fresh git worktree, drives work through
  ar-ultrawork and the Planning Triad with ar-hyperexecution, creates a reviewer-readable PR,
  then runs an unbounded verification loop (CI checks) until the PR is merged. Decomposes large
  tasks into the smallest atomic independently-mergeable PRs and builds independent ones
  concurrently via parallel subagents. Use whenever implementation work needs to land as a PR.
  Triggers: 'create a PR', 'implement and PR', 'work on this and make a PR', 'implement issue',
  'land this as a PR', 'split into atomic PRs', 'parallel PRs', 'work-with-pr', 'PR workflow',
  'implement end to end', even when user says 'implement X' if context implies PR delivery.
---

# Work With PR — Full PR Lifecycle

You are executing a complete PR lifecycle: from fresh task-owned worktree setup, through Planning Triad and ar-hyperexecution driven by ar-ultrawork discipline, PR creation, and an unbounded verification loop until the PR is merged.

**The unit of delivery is the smallest PR that compiles, passes, and stands on its own — not "one task, one PR."**

```
Phase 0: Setup         → Split into atomic PRs, branch + worktree per PR (parallel when independent)
Phase 1: Implement     → Plan via Planning Triad, execute via ar-hyperexecution under ar-ultrawork
Phase 2: PR Creation   → Push, create reviewer-readable PR targeting the default branch
Phase 3: Verify Loop   → Unbounded; a failing gate routes back to Phase 1
  └─ Gate A: CI        → gh pr checks (tests, typecheck, build)
Phase 4: Merge         → Auto-merge; wait until actually merged, then worktree cleanup
```

## Phase 0: Setup

### 1. Decide the PR split

Decompose the task into the smallest atomic PRs that each compile, pass, and deliver one reviewable slice. Prefer more small PRs over one large one.

For concurrent independent PRs:
- **Subagents** — dispatch one subagent per PR, each owning its own worktree, branch, and Phase 0→4 lifecycle.

### 2. Resolve repository context

```bash
REPO_NAME=$(basename "$PWD")
BASE_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
```

### 3. Create branch

```bash
# Auto-generate from task summary:
BRANCH_NAME="feature/$(echo "$TASK_SUMMARY" | tr '[:upper:] ' '[:lower:]-' | head -c 50 | sed 's/-$//')"
git fetch origin "$BASE_BRANCH"
git branch "$BRANCH_NAME" "origin/$BASE_BRANCH"
```

### 4. Create worktree

Place worktrees as siblings to the repo to avoid nesting issues:

```bash
WORKTREE_PATH="../${REPO_NAME}-wt/${BRANCH_NAME//\//-}"
mkdir -p "$(dirname "$WORKTREE_PATH")"
git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
cd "$WORKTREE_PATH"
```

### 5. Install dependencies

```bash
[ -f "package.json" ] && (command -v bun &>/dev/null && bun install || npm install)
[ -f "requirements.txt" ] && pip install -r requirements.txt
[ -f "go.mod" ] && go mod tidy
```

## Phase 1: Implement

Drive all implementation through `ar-ultrawork` and the Planning Triad from inside the worktree:

1. **Sizing & Plan Generation**:
   - For small, focused changes (1–2 files, 3–5 steps): Trigger `/ar-flashplan` (~3s inline) &rarr; `.ar-wf/planning/<SEQ>-YYYYMMDD-<kebab-case>.md`.
   - For standard/medium features (2–6 files, 5–10 steps): Trigger `/ar-superplan` (2-agent Builder vs Red Team).
   - For large/complex PRs (6+ files): Trigger `/ar-hyperplan` (5-agent hostile gauntlet).
2. **Execution Engine (`ar-hyperexecution`)**:
   - Drive task checkpoints sequentially via `/ar-hyperexecution` with disk-persisted state (`state.json`).
   - Capture physical verification outputs to `.ar-wf/hyper-execution/evidence/<plan-id>/task-<N>/report.txt`.
3. **Evidence-bound QA**: Every task criterion must be proven with concrete evidence (passing tests, clean linter/build, verified outputs) — not assumptions.
4. **Atomic commits**: Commit after each completed task checkbox: `git commit -m "type(scope): description"`.
5. **Parallel subagents**: Spawn subagents for independent sub-components within the worktree.

Do NOT free-hand the work. Follow the plan checklist and verification discipline.

## Phase 2: PR Creation

```bash
git push -u origin "$BRANCH_NAME"
```

Create the PR with `gh pr create`. The PR description MUST include:
- **What**: One sentence summary
- **Why**: Motivation / problem solved
- **How**: Key implementation decisions
- **Testing**: What was verified and how
- **Checklist**: [ ] tests pass, [ ] types clean, [ ] no dead code introduced

## Phase 3: Verification Loop

```bash
# Poll CI until all checks pass:
while true; do
  STATUS=$(gh pr checks "$BRANCH_NAME" --json name,state --jq '[.[] | select(.state != "SUCCESS")] | length')
  [ "$STATUS" = "0" ] && break
  echo "Waiting for CI... ($STATUS checks pending/failing)"
  sleep 30
done
```

If any check fails:
1. Fetch the failure logs: `gh run view --log-failed`
2. Fix the root cause inside the worktree
3. Commit the fix
4. Push and return to Phase 3

Do not merge a PR with failing checks.

## Phase 4: Merge and Cleanup

```bash
gh pr merge "$BRANCH_NAME" --squash --auto
# Wait for actual merge:
while [ "$(gh pr view "$BRANCH_NAME" --json state -q .state)" != "MERGED" ]; do sleep 5; done
# Cleanup:
cd ../..
git worktree remove "$WORKTREE_PATH"
git branch -d "$BRANCH_NAME"
```
