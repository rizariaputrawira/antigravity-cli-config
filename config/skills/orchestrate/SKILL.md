---
name: orchestrate
description: >-
  Master Autonomous Conductor ('God Mode'). Auto-evaluates incoming tasks,
  automatically sizes and orchestrates the planning tier (flashplan, superplan, hyperplan),
  persists canonical checklists to .workflow/plans/, and drives hyperexecution with disk-tracked
  state until all criteria are proven. Triggers: '/orchestrate', 'orchestrate', 'orc', 'god mode',
  'conductor', 'work until done', 'finish completely', 'autonomous mode'.
---

# ORCHESTRATE — Master Autonomous Conductor ("God Mode")

> **MANDATORY**: First action when this skill loads — say "⚡ ORCHESTRATE CONDUCTOR ENGAGED [ORCHESTRATE MODE ACTIVE]!" so the user knows end-to-end autonomous execution started.

---

## Overview

Where individual skills handle specific stages of development, **orchestrate is the Master Conductor**—the single-command "God Mode" entry point inspired by Oh My OpenCode (OmO).

When given a prompt via `orc` or `orchestrate`, Orchestrate manages the entire lifecycle:
1. **Intake & Triage**: Clarifies ambiguous goals (at most 1 question) and determines scope.
2. **Auto-Sizing & Planning**: Automatically selects and executes the optimal planning tier (`flashplan`, `superplan`, or `hyperplan`), emitting `.workflow/plans/<SEQ>-YYYYMMDD-<kebab-case>.md`.
3. **Hyperexecution Drive**: Hands the plan to `hyperexecution`, leveraging `.workflow/executions/` disk persistence, audit ledgers, and relentless test verification.
4. **Verified Closure**: Loops until 100% of tasks are proven and committed.

---

## Phase 0: Ambiguity Intake

Autonomous execution requires unambiguous intent:
- If the task objective, scope, or target boundary is ambiguous, **ask exactly ONE clarifying question** before proceeding.
- Pick the single most critical decision or constraint. Never ask multiple questions.
- If the task is clear, proceed immediately to Phase 1.

---

## Phase 1: 2-Gate Triage & Auto-Sizing

Classify the input through two sequential gates:

### Gate A: Plan Bypass
- If the user provides a path to an existing plan file (e.g., `orc .workflow/plans/01-20260911-add-flag.md` or legacy `.planning/...`) or specifies an active `<plan-id>`:
  - Announce that existing plan is detected.
  - Skip Phase 2 and jump directly to **Phase 3 (hyperexecution Drive)**.

### Gate B: Auto-Sizing Decision Matrix
If no plan exists, inspect target files and assess the architectural blast radius:

| Scope | Criteria | Planning Tier Triggered | Subagents | Target Time |
|---|---|---|---|---|
| **Small** | 1–2 files, localized feature/bug, 3–5 steps | [`flashplan`](../flashplan/SKILL.md) | 0 (inline) | ~3s |
| **Medium** | 2–6 files, multi-step feature/refactor, 5–10 steps | [`superplan`](../superplan/SKILL.md) | 2 (Builder vs Red Team) | ~15–20s |
| **Large / Complex** | >6 files, cross-cutting architectures, security/auth, schema rewrites | [`hyperplan`](../hyperplan/SKILL.md) | 5 (Adversarial Team) | ~45–60s |

Announce the selected tier:
> 🎯 **Scope Classified**: `[Small | Medium | Large]`. Launching `[flashplan | superplan | hyperplan]`...

---

## Phase 2: Planning Tier Orchestration

Execute the selected planning tier to produce the canonical execution checklist:

1. **Phase Separation Invariant**:
   - Planning subagents must run sequentially and **fully terminate** before any implementation begins.
   - Planning subagents and execution worker subagents must NEVER run concurrently (maximum nesting depth = 1).
2. **Sequential Numbering & Naming**:
   - Inspect `.workflow/plans/` to find the highest existing two-digit integer prefix (`<SEQ>`).
   - Assign next two-digit prefix `<SEQ>` (e.g. `01`, `02`).
   - Include current date in `YYYYMMDD` format (e.g. `20260911`).
   - Include tier (`flash`, `super`, or `hyper`).
   - Persist to: `.workflow/plans/<SEQ>-YYYYMMDD-<kebab-case>.md`.
3. **Checklist Contract**:
   - The emitted file must format tasks with checkboxes (`- [ ] **Step N: [Title]**`), target files, actions, and exact verification commands.
4. **Announce Plan Creation**:
   - Present the planned steps and confirm handoff to `hyperexecution`.

---

## Phase 3: Autonomous Hyperexecution Drive

Immediately execute the plan using the **Hyperexecution Protocol**:

1. **Scaffolding**:
   - Hand `.workflow/plans/<SEQ>-YYYYMMDD-<kebab-case>.md` to `hyperexecution`.
   - Scaffolds `.workflow/executions/runs/<plan-id>/state.json` and `notes.md`.
   - Ensures `.workflow/executions/evidence/<plan-id>/` exists and is added to `.gitignore`.
2. **Stale Recovery Check**:
   - Auto-resets tasks stuck `in_progress` >30 minutes to `pending`.
3. **Execution Loop (Numeric Order)**:
   - Evaluates tasks by numeric integer order (`1, 2, ..., 10`).
   - Applies **Orchestrate Inner Discipline**:
     - Establishes binary (pass/fail) success criteria for the active task.
     - Spawns parallel worker subagents if a sub-task exceeds >5 tool calls.
     - Implements using TDD / systematic debugging rules.
4. **Physical Evidence & Gate Check**:
   - Runs verification commands with explicit redirection:
     `<command> > .workflow/executions/evidence/<plan-id>/task-<N>/report.txt 2>&1`
     verifying exit code `$? == 0`.
5. **Circuit Breaker Handshake**:
   - If a task fails 3 verification attempts, status becomes `blocked` (`[!]`).
   - Orchestrate halts execution immediately and escalates to user:
     > 🚨 Task `<N>` failed 3 times. What would you like to do? [retry / skip / abort]
   - Never enter an infinite retry loop without user resolution.
6. **Atomic Commits & Ledger Logging**:
   - Creates atomic commit per task: `git commit -m "feat(<scope>): <title>"`.
   - Appends `task-completed` event to `.workflow/executions/ledger.jsonl`.
   - Updates plan checkbox to `[x]`.

---

## Phase 4: Final Verification & Closure Report

Once all tasks reach `[x]`:

1. **Repository Sanity Check**:
   - Run existing test suites or typechecks to verify zero collateral regressions.
2. **Conductor Summary Card**:
   Emit a final summary card detailing: (1) Plan path & sizing tier, (2) Tasks completed (`[M / M]` 100% proven), (3) Audit & evidence paths (`state.json`, `ledger.jsonl`, `evidence/`), and (4) Commits created.

---

## Conductor Invariants (Never Violate)

- **Never bypass the intake question** when a prompt is genuinely ambiguous.
- **Never proceed to execution** without a validated `.workflow/plans/<SEQ>-YYYYMMDD-<kebab-case>.md` checkbox file.
- **Never run planning subagents and execution subagents concurrently** (enforce Phase Separation).
- **Never use colons** in evidence directory or filenames (NTFS safety).
- **Never ignore the circuit breaker** — halt and escalate when `retry_count >= 3`.
- **Never self-certify completion** without physical evidence in `report.txt`.
