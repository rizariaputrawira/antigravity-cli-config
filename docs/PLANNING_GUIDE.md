# The Antigravity Planning & Execution Workflow

The Antigravity CLI Config ships with a robust, multi-tier orchestration architecture designed to prevent autonomous agents from running out of control, hallucinating code, or getting stuck in infinite loops. 

This guide explains the workflow and how to interact with the five primary orchestration skills: `brainstorm`, `flashplan`, `superplan`, `hyperplan`, and `hyperexecution`, all unified under the `orchestrate` ("God Mode") conductor.

## 1. Discovery & Design: `/brainstorm`

Before any code is written, you must chart the territory.
- **Trigger**: `/brainstorm` or "let's design this"
- **Purpose**: Explores user intent, uncovers edge cases, and maps complex problem domains before implementation begins.
- **Output**: Generates a canonical design specification saved to `.workflow/brainstorm/<SEQ>-YYYYMMDD-<kebab-case>-design.md`. 
- **Fog of War**: Explicitly separates the **actionable frontier** (work that can be planned now) from **unspecifiable future work** (the fog) so agents don't hallucinate future constraints.

## 2. The Planning Tiers

Once a design spec is created, it must be formalized into an atomic execution checklist (`.workflow/plans/`). The tier you choose depends on the scope of the task.

| Scope | Tier | Parallel Subagents | Target Time | Description |
|---|---|---|---|---|
| **Small** | `/flashplan` | 0 (Inline) | ~3s | Instant, surgical planning for 1-2 files. Minimal diff filter, strict YAGNI. |
| **Medium** | `/superplan` | 2 (Builder vs Red Team) | ~15-20s | Fast 2-agent pragmatic review (Research + Arch vs Skeptic + Validator). |
| **Large** | `/hyperplan` | 5 (Adversarial Team) | ~45-60s | Hostile planning. 5 subagents ruthlessly attack each other's ideas to forge a defensible plan. |

**Important Constraint**: Planning skills NEVER automatically execute code. They strictly generate `.workflow/plans/<SEQ>-...md` and halt, requiring human confirmation before execution begins.

## 3. The Execution Engine: `/hyperexecution`

Once a plan is approved, it is handed to the execution engine.
- **Trigger**: `/hyperexecution .workflow/plans/<plan-id>.md` or "start work"
- **Purpose**: Relentless, disk-persisted autonomous execution that survives terminal restarts and agent handoffs.
- **State Tracking**: Uses local FSM state (`.workflow/executions/runs/<plan-id>/state.json`) and an append-only event ledger (`ledger.jsonl`).
- **Orchestrate Discipline**: 
  - Establishes pass/fail binary success criteria for every task.
  - Spawns parallel worker subagents for tasks taking >5 tool calls.
  - **Evidence is mandatory**: Captures raw terminal verification output (e.g. test results) to `.workflow/executions/evidence/<plan-id>/task-<N>/report.txt`.
  - Halts and escalates to the user if a task fails 3 verification attempts (Circuit Breaker).

## 4. The Master Conductor: `/orchestrate`

If you want the entire lifecycle managed autonomously, use the Conductor.
- **Trigger**: `/orchestrate` or "orc"
- **Purpose**: The "God Mode" entry point. 
- **Flow**:
  1. Intake: Clarifies ambiguous intent.
  2. Auto-Sizing: Automatically evaluates the codebase blast radius and selects the correct planning tier (`flashplan`, `superplan`, or `hyperplan`).
  3. Handoff: Seamlessly passes the generated plan to `hyperexecution`.
  4. Loop: Drives the execution engine relentlessly until all checkboxes are proven green with physical evidence.


