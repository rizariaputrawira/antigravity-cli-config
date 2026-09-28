---
name: remove-deadcode
description: >-
  Systematically finds and removes dead code: unused exports, unreferenced variables,
  commented-out blocks, unreachable code, and unused dependencies. Uses grep, language
  tooling (knip, ts-prune, depcheck), and AST analysis. Verifies nothing breaks after
  removal. Use when asked to remove dead code, clean up unused code, find unused exports,
  prune the codebase, or reduce bundle size. Triggers: 'remove dead code', 'clean unused
  code', 'find unused exports', 'prune codebase', 'dead code removal', 'remove-deadcode'.
---

# Remove Dead Code — Systematic Dead Code Elimination

Safely find and remove dead code with verification at each step. Every removal must be proven unused first.

## Safety Rules

1. **Never remove code without proving it's unused first.**
2. **Verify tests still pass after each batch of removals.**
3. **Commit in small batches** — one category per commit.
4. **When in doubt, flag it** — don't delete speculatively.

## Phase 0: Detect Language Stack

```bash
ls package.json pyproject.toml go.mod Cargo.toml 2>/dev/null
```

## Phase 1: Find Dead Code (spawn parallel subagents per category)

### Category A: Unused Exports (TypeScript/JavaScript)

```bash
# knip (best for TS/JS):
npx knip --reporter json 2>/dev/null

# ts-prune fallback:
npx ts-prune 2>/dev/null
```

### Category B: Commented-Out Code

```bash
# Find commented-out blocks (3+ consecutive comment lines)
grep -rn "^\s*//" --include="*.ts" --include="*.js" . | head -100
```

### Category C: Unused Dependencies

```bash
npx depcheck 2>/dev/null
# Or manually check package.json deps against imports
```

### Category D: TypeScript Unused Locals

```bash
npx tsc --noEmit --noUnusedLocals --noUnusedParameters 2>&1 | grep "never read\|never used"
```

## Phase 2: Triage

For each finding, confirm it's truly unused:
- Verify zero internal callers using local MCP `lsp_references` (`Arguments: {"file": "<path>", "line": <line - 1>, "character": <col>}`) or `grep_search`.
- Do NOT delete:
  - Public API exports (may be used by external consumers)
  - Test fixtures/helpers
  - Code guarded by feature flags
  - Anything with `// intentionally unused` comment

## Phase 3: Remove (batched with verification)

For large dead code removals (>2 files or multi-category), formalize into an execution plan via [`/superplan`](../superplan/SKILL.md) executed by [`/hyperexecution`](../hyperexecution/SKILL.md).

For each batch:
1. Remove the code
2. `npx tsc --noEmit` (or typecheck) — must pass
3. Run test suite — must pass
4. Capture verification output into `.workflow/executions/evidence/<plan-id>/task-<N>/report.txt` (or local evidence)
5. `git commit -m "chore(deadcode): remove unused [category]"`

If anything breaks, revert the batch and investigate.

## Phase 4: Report

Write `DEAD_CODE_REMOVED.md` with:
- Files modified, lines removed
- List of removed items (file:line)
- Items kept as intentional
- Recommended follow-ups
