---
name: ar-hyperexecution
description: >-
  Advanced disk-persisted state tracking and autonomous execution for massive,
  multi-session tasks with built-in Ultrawork discipline (maximum autonomous effort).
  Uses .ar-wf/planning/*.md checkboxes as the canonical source of truth. Saves evidence to
  .ar-wf/hyper-execution/evidence/<plan-id>/, appends execution logs to
  .ar-wf/hyper-execution/ledger.jsonl, and tracks plan-scoped state in
  .ar-wf/hyper-execution/executions/<plan-id>/state.json. Survives terminal restarts and
  multi-session handoffs. Integrates with ar-hyperplan, ar-superplan, and ar-flashplan output.
  Triggers: '/ar-hyperexecution', 'ar-hyperexecution', 'hyperexecution', 'hyper-execution', 'execute plan', 'start work
  on', 'resume work', 'continue hyperexecution', 'continue boulder',
  'boulder-execution'
---

# AR-HYPEREXECUTION — Relentless Disk-Persisted Plan Execution

> **MANDATORY**: First action when this skill loads — say "⚡ AR-HYPEREXECUTION ENABLED [ULTRAWORK DISCIPLINE ACTIVE]!" so the user knows relentless, maximum-effort execution started.

## Overview

When executing complex plans (3-step ar-flashplan, 5-to-10 step ar-superplan, or 20+ task ar-hyperplan), use the
**Hyperexecution Pattern** — disk-persisted state combined with **Ultrawork's maximum-effort autonomous execution discipline** that survives terminal restarts and agent handoffs.

**Source of truth**: The `.ar-wf/planning/<plan-id>.md` checkbox file (with automatic fallback to legacy `.planning/<plan-id>.md` if specified or present).
- `[ ]` = pending
- `[-]` = in_progress
- `[x]` = completed
- `[!]` = blocked / failed

The state file (`.ar-wf/hyper-execution/executions/<plan-id>/state.json`) is a _supplementary
tracker_ for metadata (timestamps, retry counts, evidence paths). The plan
markdown is always authoritative.

---

## Directory Structure

```
.ar-wf/hyper-execution/
  executions/
    <plan-id>/
      state.json        # Supplementary tracker (NOT source of truth)
      notes.md          # Single scratchpad: decisions, issues, learnings, blockers
  evidence/
    <plan-id>/
      task-<N>/
        report.txt      # Raw verification output
  ledger.jsonl          # Append-only event log (project root .ar-wf/hyper-execution/)
```

**`<plan-id>`** is the filename stem of the planning file, e.g., for
`.ar-wf/planning/01-20260911-auth-feature.md` → plan-id = `01-20260911-auth-feature`.

> **`.gitignore` instruction**: On first scaffold, append `.ar-wf/hyper-execution/evidence/` to
> `.gitignore` if it is not already present. Evidence files are large and
> volatile — never commit them.

---

## Canonical Schemas

### `.ar-wf/hyper-execution/executions/<plan-id>/state.json`

```json
{
  "schema_version": 3,
  "plan_id": "01-20260911-auth-feature",
  "plan_file": ".ar-wf/planning/01-20260911-auth-feature.md",
  "created_at": "<ISO-8601>",
  "updated_at": "<ISO-8601>",
  "tasks": {
    "1": {
      "title": "Setup database schema",
      "status": "pending",
      "retry_count": 0,
      "started_at": null,
      "ended_at": null,
      "elapsed_ms": null,
      "evidence_path": null,
      "commit": null
    }
  }
}
```

**Status FSM**:
```
pending → in_progress → completed
                     ↘ failed (verification failed, retry_count < 3)
                     ↘ blocked (retry_count ≥ 3 OR explicit user block)
```

### `.ar-wf/hyper-execution/ledger.jsonl` (append-only, one JSON object per line)

Each line must be one of:

```jsonc
// Task state change
{"event":"task-started","plan_id":"01-20260911-auth-feature","task":"1","title":"...","ts":"<ISO-8601>"}
{"event":"task-completed","plan_id":"01-20260911-auth-feature","task":"1","title":"...","commit":"<hash>","evidence":".ar-wf/hyper-execution/evidence/01-20260911-auth-feature/task-1/report.txt","elapsed_ms":12400,"ts":"<ISO-8601>"}
{"event":"task-failed","plan_id":"01-20260911-auth-feature","task":"1","retry_count":2,"reason":"...","ts":"<ISO-8601>"}
{"event":"task-blocked","plan_id":"01-20260911-auth-feature","task":"1","retry_count":3,"reason":"...","ts":"<ISO-8601>"}
// Recovery events
{"event":"stale-recovery","plan_id":"01-20260911-auth-feature","task":"1","stale_since":"<ISO-8601>","action":"reset-to-pending","ts":"<ISO-8601>"}
{"event":"user-confirmation","plan_id":"01-20260911-auth-feature","task":"1","result":"yes","ts":"<ISO-8601>"}
```

> Ledger path is always `.ar-wf/hyper-execution/ledger.jsonl` — **no subdirectory**. Never
> rewrite, truncate, or delete any entry.

---

## Phase 1: Start Work

When "start work on [plan]", "hyperexecution [plan]", or "execute plan [plan]":

1. **Locate the plan**: Find `.ar-wf/planning/<plan-id>.md` (or fallback to `.planning/<plan-id>.md` if user explicitly passes legacy path). If multiple plans exist,
   ask the user which one. If none exist, ask or offer to run `/ar-flashplan`, `/ar-superplan` or `/ar-hyperplan`.

2. **Scaffold `.ar-wf/hyper-execution/`**:
   - Create `.ar-wf/hyper-execution/executions/<plan-id>/` if it doesn't exist.
   - Create `state.json` with all tasks parsed from the plan's checkbox lines
     (`[ ]` items), using **numeric sort** on the integer suffix (see Task
     Ordering below).
   - Create `.ar-wf/hyper-execution/executions/<plan-id>/notes.md` with header:
     ```
     # Notes — <plan-id>
     _Append-only. Never overwrite. Sections: ## Decisions, ## Issues, ## Learnings, ## Blockers_
     ```
   - Ensure `.ar-wf/hyper-execution/evidence/<plan-id>/` directory exists.
   - Append `.ar-wf/hyper-execution/evidence/` to `.gitignore` if not already present.

3. **Announce**: Print a summary of tasks found and their order, declaring Ultrawork discipline active.

---

## Phase 2: Resume / Execution Loop (Ultrawork Driven)

When "resume work", "continue hyperexecution", or during the autonomous loop:

### 2a. Stale `in_progress` Recovery

Before executing anything, scan `state.json` for tasks with status
`in_progress`. For each:

- If `started_at` is **>30 minutes ago** (or process cannot be confirmed
  running): reset status to `pending`, update checkbox to `[ ]`, append a
  `stale-recovery` event to the ledger, and **warn the user**:
  > ⚠️ Task `<N>` ("title") was stuck `in_progress` since `<started_at>`.
  > Auto-reset to `pending`.

### 2b. Task Selection

1. Read the `.ar-wf/planning/<plan-id>.md` file (source of truth).
2. Find the lowest-numbered `[ ]` or `[-]` (failed, retry eligible) checkbox
   using **numeric sort** on the integer suffix (see Task Ordering).
3. If none found:
   - All `[x]` → plan is complete. Announce victory and stop.
   - Only `[!]` remain → announce blocked tasks and ask user how to proceed.

### 2c. Execute Task (Ultrawork Discipline Engine)

1. **Update state**: Set `in_progress` in `state.json`, set `started_at`,
   update checkbox to `[-]`. Append `task-started` to ledger.
2. **Inject context**: Read `.ar-wf/hyper-execution/executions/<plan-id>/notes.md` and include
   its full contents as context before beginning the task.
3. **Binary Decomposition (Ultrawork Phase 1)**:
   - Identify 1–2 explicit, verifiable binary success criteria for the active task (pass/fail).
   - Never accept subjective quality ("looks good"). Must have a concrete command or check that proves completion.
4. **Autonomous Delegation Heuristic (Ultrawork Phase 2)**:
   - If a sub-task requires deep exploratory work (>5 tool calls) or is cleanly parallelizable, spawn a focused subagent with read-only state access.
   - Pass `plan_id`, paths to `.ar-wf/planning/<plan-id>.md`, `notes.md`, and target files (subagent must read `notes.md` before executing).
   - Subagents report raw evidence back to the parent orchestrator via message; the parent orchestrator retains exclusive write access to `state.json` and `ledger.jsonl`.
   - Parent collects returned evidence into `.ar-wf/hyper-execution/evidence/<plan-id>/task-<N>/report.txt` and performs atomic commits.
5. **Implement with Discipline**:
   - Apply `test-driven-development` and `systematic-debugging` rules.
   - Refuse to stop prematurely. Loop autonomously until criteria are met.
   - **Transactional `lsp_rename` for Cross-File Refactoring**:
     - When performing cross-file symbol refactoring, invoke local MCP `call_mcp_tool(ServerName="lsp", ToolName="lsp_rename", Arguments={"file": "<file>", "line": <line_0idx>, "character": <char_0idx>, "newName": "<new_name>"})`.
     - Strictly enforce the 3-step safety check:
       1. Convert editor/grep coordinates to 0-indexed integers (`lsp_line = line - 1`, `lsp_character = character - 1`).
       2. Inspect blast radius beforehand using `lsp_references` (0-indexed).
       3. Run `git diff --stat` immediately post-rename to audit touched files before running tests.
   - **Pre-Test Formatting**:
     - Run the project formatter CLI (`npm run fmt`, `cargo fmt`, `ruff format`, `black`, `prettier`) or local MCP `call_mcp_tool(ServerName="lsp", ToolName="lsp_formatting", Arguments={"file": "<file>"})` at the END of Phase 2c *before* running Phase 3 verification.
     - *Invariant*: Formatting in Phase 4 is strictly prohibited (Phase 4 commits only code that was already verified by tests).
6. **Append discoveries** to `notes.md` under the relevant section
   (`## Decisions`, `## Issues`, `## Learnings`, `## Blockers`).

---

## Phase 3: Evidence & Verification (Ultrawork Gate Check)

Before claiming a task is done, **evidence is mandatory**:

### Advisory Pre-Flight Check (Local LSP Diagnostics)
- For code edits in supported languages, run advisory pre-flight diagnostics:
  `call_mcp_tool(ServerName="lsp", ToolName="lsp_diagnostics", Arguments={"file": "<touched_file>", "scope": "file"})`.
- **Non-blocking & Advisory**: If syntax or type errors are reported, note them in `notes.md` and attempt immediate in-memory fix before running the main test suite.
- **Graceful Degradation**: If the LSP server is uninitialized, unsupported for the filetype, or errors out, silently skip without stalling or failing the task.
- **Strict Read-Only Verification**: Auto-healing via `lsp_code_action` is **strictly banned** during Phase 3 verification gates to prevent arbitrary, non-deterministic edits. The gate is strictly read-only.
- Terminal verification commands below remain the sole authoritative completion gate.

### Authoritative Verification Command
1. Run the verification command defined in the task (tests, build, curl, etc.).
2. Save the **raw output** using explicit redirection:
   `<command> > .ar-wf/hyper-execution/evidence/<plan-id>/task-<N>/report.txt 2>&1`
   and verify exit code `$? == 0`.

### Deterministic Inspection for Non-Executable Tasks
If a task is documentation, configuration, or structural (no dedicated test suite):
- Do NOT ask the user trivial confirmation questions.
- Run a deterministic inspection command (e.g. `test -s <file> && grep -Fq '<target>' <file>` or `git diff --stat`) and pipe the output to `report.txt`.

### Ultrawork Gate Check & Circuit Breaker Linkage
Evaluate the binary success criteria:
- Are ALL criteria PROVEN with evidence in `report.txt`?
- **If YES**: Proceed to Phase 4 (Commit & Ledger).
- **If NO**:
  1. Increment `retry_count` in `state.json`.
  2. Append a `task-failed` event to `.ar-wf/hyper-execution/ledger.jsonl`.
  3. If `retry_count < 3`: Loop back autonomously to Phase 2c to fix the failure. Never self-certify without passing evidence.
  4. If `retry_count >= 3`: Trip the circuit breaker:
     - Set status to `blocked` in `state.json`.
     - Update checkbox in `.ar-wf/planning/<plan-id>.md` to `[!]`.
     - Append `task-blocked` to ledger and `## Blockers` to `notes.md`.
     - **Escalate to user**:
       > 🚨 Task `<N>` ("title") has failed 3 verification attempts. What would you like to do? [retry / skip / abort]
     - Wait for user response before continuing.

---

## Phase 4: Commit & Ledger

Once verified (evidence file shows pass):

1. **Commit atomically**: `git commit -m "feat(<scope>): <title>"`
2. **Update state**:
   - Set `completed` in `state.json`.
   - Set `ended_at`, compute `elapsed_ms`, record `commit` hash, set
     `evidence_path`.
   - Update checkbox in `.ar-wf/planning/<plan-id>.md` to `[x]`.
3. **Append to ledger**: `task-completed` entry with all fields.
4. **Loop**: Return to Phase 2b for the next pending task.

---

## Task Ordering Rule

> **CRITICAL**: Task ordering must use **numeric sort** on the integer suffix,
> NOT lexicographic string sort.

Correct order: `1, 2, 3, ..., 9, 10, 11, ...`
Wrong (lexicographic): `1, 10, 11, 2, 3, ...`

When extracting task numbers from checkbox lines (e.g., `- [ ] Task 10: ...`),
parse the integer and sort numerically before building the execution queue.

---

## Invariants (Never Violate)

- **Never rewrite** the ledger. It is append-only forever.
- **Never claim completion** without a physical evidence file in `report.txt`.
- **Never stop prematurely** in Phase 2c/Phase 3 — loop until the Ultrawork Gate Check is 100% proven or 3 retries trip the circuit breaker.
- **Never ask trivial confirmation questions** when a deterministic shell inspection can verify the change.
- **Never skip the stale-recovery check** on resume.
- **Never use lexicographic sort** for task ordering.
- **Never use colons** in evidence or evidence directory names.
- **Never proceed past 3 failures** without user escalation.
