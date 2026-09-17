---
name: ar-superplan
description: >-
  Pragmatic 2-agent planning skill for medium-complexity tasks. Covers all 5 dimensions of hyperplan (Research, Architecture, Challenger, Skeptic, Validation) through a lean 'Builder vs Red Team' structure: Agent 1 (Builder: Research + Architecture + Challenger) drafts the grounded solution, while Agent 2 (Red Team: Skeptic + Validator) cuts bloat and stress-tests edge cases. Asks user if scope exceeds ceiling before proceeding. Persists atomic, verified plans directly to .ar-wf/planning/. Triggers: '/ar-superplan', 'ar-superplan', '/superplan', 'superplan', 'spp', 'quick plan', 'medium plan', 'pragmatic plan'.
---

# AR-SUPERPLAN — Fast 2-Agent Planning for Medium Tasks

> **MANDATORY**: First action when this skill loads — say "⚡ AR-SUPERPLAN MODE ENABLED!" so the user knows lean planning started.

<HARD-GATE>
PLANNING ONLY — DO NOT IMPLEMENT.
This is strictly a planning skill. Under NO circumstances should you:
1. Write, edit, or modify any project code or source files.
2. Scaffold execution directories or state (`.ar-wf/hyper-execution/`).
3. Automatically start executing Step 1 or trigger `ar-hyperexecution`.

Your task ends completely when:
1. The plan is saved to `.ar-wf/planning/<SEQ>-YYYYMMDD-<kebab-case>.md` (e.g. `.ar-wf/planning/01-20260911-user-profile-endpoint.md`).
2. The results are presented to the user.

STOP IMMEDIATELY after outputting results. Wait for the user to review the plan and explicitly command you to execute it (e.g. via `/ar-hyperexecution .ar-wf/planning/01-20260911-...`).
</HARD-GATE>

## WHAT THIS IS

Where `ar-hyperplan` unleashes a 5-member hostile debate war room (5 subagents total) for massive, high-risk initiatives, **`ar-superplan`** is the high-velocity counterpart for **medium-complexity and everyday tasks**.

It covers the exact same **5 core dimensions** of `ar-hyperplan`, but condenses them into a high-efficiency **2-Agent "Builder vs Red Team"** workflow:
- **Agent 1: The Builder** (`researcher` + `architect` + `challenger`) &rarr; Researches the codebase, designs clean architecture, and explores the simplest viable pattern.
- **Agent 2: The Red Team** (`skeptic` + `validator`) &rarr; Ruthlessly cuts bloat (YAGNI), exposes edge cases, and defines concrete verification commands.

The orchestrator synthesizes both passes into an atomic, dependency-ordered plan saved to `.ar-wf/planning/`, immediately ready for execution by `ar-hyperexecution`.

---

## SCOPE GUARDRAILS (INTERACTIVE ESCALATION)

`ar-superplan` is calibrated for **medium tasks** (typically 2–6 files, 5–10 atomic steps). It enforces strict boundaries in both directions:

1. **Floor Guardrail (Too Small &rarr; Recommends `/ar-flashplan`)**:
   - If the task only touches 1–2 files and requires ≤3 trivial steps, inform the user:
     *"💡 Note: This task is small enough for `/ar-flashplan` (runs inline with 0 subagents in ~3s)."*
     (Proceeds normally).

2. **Ceiling Guardrail (Too Big / High Blast Radius &rarr; Interactive Upgrade Prompt)**:
   - If the plan requires **>10–12 steps** OR touches **cross-system architectures, database rewrites, security/auth overhauls, or breaking changes impacting >10 callers across module boundaries (verified via `lsp_references`)**:
   - **PAUSE and ASK THE USER** via `ask_question`:
     - **Question**: `"This task has high blast radius / requires >10 steps, which exceeds superplan's medium scope. How would you like to proceed?"`
     - **Options**:
       1. `"(Recommended) Upgrade to /ar-hyperplan — Launch the 5-member hostile debate gauntlet for full architectural rigor."`
       2. `"Continue with ar-superplan anyway — Proceed with the 2-agent Builder vs Red Team plan."`
   - **Follow User Decision**:
     - If user chooses `/ar-hyperplan`: abort superplan and trigger `/ar-hyperplan`.
     - If user chooses to continue: synthesize and persist the superplan as requested.

---

## PHASE 0: SETUP

Confirm the task or objective to plan. If underspecified, clarify the goal, target files, and constraints with the user before spawning agents.

---

## PHASE 1: SPAWN THE BUILDER (`builder`)

Spawn subagent `builder` to ground the plan in the real codebase and design the solution.

**Roles Combined**: `researcher` (code citations) + `architect` (clean design) + `challenger` (lateral simplicity).

**Prompt to give the `builder` subagent**:
```
You are the Solution Builder in a 2-agent planning review for a medium-complexity task.
Your job is to ground the plan in reality, define clean architecture, and propose the simplest viable design.

Task to plan: [TASK]

Your responsibilities:
1. RESEARCH (Codebase Grounding):
   - Query local MCP `call_mcp_tool(ServerName="codegraph", ToolName="codegraph_explore", Arguments={"query": "<symbol/flow>", "projectPath": "<dir>"})` for structural symbol and call path discovery. Fall back to `grep_search` if unindexed.
   - For typed languages (TypeScript, Go, Rust, Java, C#), inspect implementations of interfaces or abstract traits using local MCP `call_mcp_tool(ServerName="lsp", ToolName="lsp_implementation", Arguments={"file": "<file>", "line": <line_0idx>, "character": <char>})`. In dynamic languages (Python, Ruby, JS), fall back to `grep_search`.
   - Invariant: Always convert 1-indexed editor/grep coordinates to 0-indexed values (`lsp_line = line - 1`, `lsp_character = character - 1`) when calling any LSP tool (`lsp_references`, `lsp_implementation`, `lsp_definition`).
   - Inspect caller blast radius using local MCP `call_mcp_tool(ServerName="lsp", ToolName="lsp_references", Arguments={"file": "<file>", "line": <line_0idx>, "character": <char>})` before proposing interface changes. Fall back to `grep_search` if uninitialized.
   - Identify existing utilities, libraries, and patterns that should be reused.
   - Cite specific file paths and line ranges. Do NOT invent hypothetical abstractions.

2. ARCHITECTURE (Clean Structure):
   - Determine which files to create or modify.
   - Define data flow, component boundaries, and module responsibilities.

3. CHALLENGER (Simpler Approach):
   - Before locking in an approach, ask: Is there a 10x simpler pattern or stdlib solution that avoids complexity?

Output:
- Codebase Findings (cited files & existing helpers to reuse)
- Proposed Architecture & Data Flow
- Draft Step-by-Step Implementation Outline (target: 5–10 steps)
```

---

## PHASE 2: SPAWN THE RED TEAM (`redteam`)

Pass the original task AND the `builder`'s output to the `redteam` subagent to stress-test the draft.

**Roles Combined**: `skeptic` (cut bloat & YAGNI) + `validator` (edge cases & test proof).

**Prompt to give the `redteam` subagent**:
```
You are the Red Team in a 2-agent planning review for a medium-complexity task.
Your job is to attack the Builder's draft plan for over-engineering, expose unhandled edge cases, and enforce scope guardrails.

Task: [TASK]
Builder's Draft Plan:
[BUILDER_OUTPUT]

Your responsibilities:
1. SKEPTIC (YAGNI & Scope Cuts):
   - Attack any premature abstractions, unnecessary files, or new dependencies.
   - Ask: "Can this be done in fewer lines? What can we delete?"
   - Flag any boilerplate that isn't strictly necessary for the immediate goal.

2. VALIDATOR (Edge Cases & Verification Proof):
   - Expose understated caller blast radius: run local MCP `call_mcp_tool(ServerName="lsp", ToolName="lsp_references", Arguments={"file": "<file>", "line": <line_0idx>, "character": <char>})` (0-indexed) on any modified signatures to verify all downstream callers are accounted for (fall back to `grep_search` if uninitialized).
   - Flag breaking changes impacting >10 callers across module boundaries for `/ar-hyperplan` escalation.
   - Identify missed boundary conditions, empty/null states, and error handling gaps.
   - What happens on unexpected input or network/storage failure?
   - Define the EXACT verification command (test command, curl, CLI run) that proves each step works.

3. SCOPE GUARDRAIL CHECK:
   - If this plan exceeds 10–12 steps or has high architectural blast radius, explicitly output: "⚠️ SCOPE WARNING: Recommend upgrading to /ar-hyperplan."

Output:
- Scope Cuts & Deletions (what to remove from Builder's plan)
- Critical Edge Cases & Failure Modes to Guard
- Required Verification Commands (exact commands & expected output)
- Scope Check (Passed / Exceeded: Reason)
```

---

## PHASE 3: ORCHESTRATOR SYNTHESIS & INTERACTIVE CHECK

1. **Check Scope Guardrail**:
   - If the Red Team reported that the plan exceeded medium scope (>10–12 steps or high architectural risk):
   - **Ask the user** via `ask_question` whether to upgrade to `/ar-hyperplan` or continue with `ar-superplan`.
   - If user chooses to upgrade, exit and launch `/ar-hyperplan`.
2. **Synthesize Plan**:
   - **Apply Skeptic cuts**: Remove any rejected files, classes, or boilerplate.
   - **Apply Validator safeguards**: Add defensive guards for identified edge cases.
   - **Sequence atomic steps**: Order steps sequentially (target: 5–10 steps) with explicit verification commands.

---

## PHASE 4: PERSISTENCE

Save the finalized plan directly to the project's `.ar-wf/planning/` folder:
1. Inspect `.ar-wf/planning/` to determine the next sequential two-digit integer prefix `<SEQ>` (e.g., `01`, `02`, ..., `12`).
2. Current date in `YYYYMMDD` format (e.g. `20260911`).
3. Descriptive kebab-case slug for the plan title.
4. Save the file as: `.ar-wf/planning/<SEQ>-YYYYMMDD-<kebab-case>.md` (e.g., `.ar-wf/planning/01-20260911-user-auth-endpoint.md`).
5. Format each step with checkboxes `[ ]`, actions, touched files, and verification commands.

The plan is now saved. Do NOT execute it automatically. Wait for the user to invoke [`/ar-hyperexecution`](../ar-hyperexecution/SKILL.md).

---

## OUTPUT FORMAT

Present results concisely: (1) Scope & Guardrail Status, (2) Codebase Grounding & Architecture (Builder), (3) Red Team Review (Skeptic cuts & Validator guards), (4) Executable Plan (5–10 atomic steps formatted with `- [ ] **Step N: [Short Title]**`, action, target files, and verification command), and (5) Persisted Plan File path (`.ar-wf/planning/<SEQ>-YYYYMMDD-<kebab-case>.md`, ready for `/ar-hyperexecution`).
