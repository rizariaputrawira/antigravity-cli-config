---
name: tech-debt-audit
description: >-
  Thorough file-cited technical debt audit across 9 dimensions using grep, AST analysis,
  language-native tooling, and optional CodeGraph MCP. Produces TECH_DEBT_AUDIT.md with
  severity ratings, effort estimates, and prioritized fixes. Use when asked for codebase
  health check, tech debt audit, architecture review, code quality assessment, or cleanup
  planning. Triggers: 'tech debt', 'technical debt', 'debt audit', 'code health',
  'codebase health check', 'find tech debt', 'debt analysis', 'audit code quality'.
---

# Tech Debt Audit Protocol

Thorough, file-cited technical debt audit. Uses grep, glob, bash, and read tools plus local MCP accelerators (`codegraph_explore` for symbol hierarchies, `lsp_references` for caller blast radius, `lsp_diagnostics` for compiler errors). Produces a grounded, citable `TECH_DEBT_AUDIT.md` artifact.

## Output

Write results to `TECH_DEBT_AUDIT.md` in the repo root:

1. **Executive Summary** — 3-5 sentences: overall health, worst dimension, quick wins count
2. **Mental Model** — the repo's architecture in 1 paragraph
3. **Findings Table** — columns: ID | Category | File:Line | Severity (Critical/High/Medium/Low) | Effort (Hours) | Description | Recommendation
4. **Top 5 Priorities** — ranked by impact/effort ratio
5. **Quick Wins Checklist** — items under 30 minutes each
6. **"Looks Bad But Is Fine"** — intentional patterns that look like debt
7. **Open Questions** — things the maintainer should clarify

## Phase 0: Orient

1. Map the language stack (look for package.json, pyproject.toml, go.mod, Cargo.toml, etc.)
2. Check dependencies and build tooling
3. Run `git log --oneline -200` — find highest-change files (churn)
4. Find largest files (>300 LOC are candidates)
5. Cross-reference high-churn + large = debt hot zones
6. Write the mental model paragraph

## Phase 1: Audit Across 9 Dimensions (run in parallel subagents)

Spawn up to 9 parallel subagents, each auditing one dimension. Every finding MUST cite `file:line`.

### Dimension 1: Architectural Decay
- Look for circular imports/dependencies
- Find god classes/modules (>500 LOC with >10 public methods)
- Find `TODO|FIXME|HACK|XXX|WORKAROUND|TEMP` markers
- Identify misplaced async boundaries

### Dimension 2: Dead Code
- Find exported symbols with zero internal callers
- Find commented-out code blocks (>5 lines)
- Find unused imports and variables
- Find unreachable code after early returns

### Dimension 3: Duplication
- Find copy-pasted blocks (>20 identical lines in different files)
- Find near-identical functions that should be generalized
- Find repeated configuration constants that should be centralized

### Dimension 4: Test Coverage Gaps
- Find files/functions with no corresponding test file
- Find tests that are just `expect(true).toBe(true)` or equivalent stubs
- Find critical business logic with no tests

### Dimension 5: Error Handling
- Find bare `catch(e) {}` (swallowed errors)
- Find missing error propagation in async code
- Find `as any` / `as unknown` casts that hide type errors
- Find unhandled promise rejections

### Dimension 6: Performance Risks
- Find N+1 query patterns
- Find unbounded loops over large collections
- Find missing pagination in list operations
- Find synchronous I/O in async contexts

### Dimension 7: Security Surface
- Find user-controlled strings used in shell commands
- Find hardcoded secrets or API keys (grep for `password|secret|api_key|token` near string literals)
- Find missing input validation at API boundaries
- Find path traversal risks in file operations

### Dimension 8: Dependency Health
- List outdated major-version dependencies
- Find dependencies with known CVEs (check npm audit, pip-audit, etc.)
- Find unused dependencies in package manifests
- Find duplicate dependencies at different versions

### Dimension 9: Documentation Gaps
- Find public APIs/functions with no docstrings
- Find complex algorithms with no explanatory comments
- Find README sections that reference non-existent files or outdated commands

## Phase 2: Synthesis

Collect all findings from all subagents. Deduplicate. Rank by impact/effort ratio. Write `TECH_DEBT_AUDIT.md`.

## Phase 3: Remediation Handoff

Once `TECH_DEBT_AUDIT.md` is delivered, route remediation into the Planning Triad:
- **Quick Wins (<30 min, 1–2 files)**: Launch [`/ar-flashplan`](../ar-flashplan/SKILL.md) &rarr; `.ar-wf/planning/<SEQ>-YYYYMMDD-<kebab-case>.md`.
- **Medium Refactors (2–6 files, dead code pruning, duplicate consolidation)**: Launch [`/ar-superplan`](../ar-superplan/SKILL.md) (Builder vs Red Team).
- **Architectural Overhauls (Major subsystem decoupling, circular dependency elimination)**: Launch [`/ar-brainstorm`](../ar-brainstorm/SKILL.md) &rarr; [`/ar-hyperplan`](../ar-hyperplan/SKILL.md).
- **Execution**: Drive remediation via [`/ar-hyperexecution`](../ar-hyperexecution/SKILL.md) under [`ar-ultrawork`](../ar-ultrawork/SKILL.md) discipline, capturing verification proof into `.ar-wf/hyper-execution/evidence/<plan-id>/task-<N>/report.txt`.
