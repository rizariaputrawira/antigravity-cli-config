---
name: flashplan
description: >-
  Instant, surgical planning skill for small, focused tasks (1–2 files, localized bug fixes, CLI flags, minor additions). Runs inline (0 subagents) in ~3 seconds. Enforces mandatory codebase grounding, YAGNI/minimal diff filter, and strict verification commands, persisting a 3–5 step plan directly to .workflow/plans/. Asks user if scope exceeds ceiling before proceeding. Triggers: '/flashplan', 'flashplan', 'flp', 'fast plan', 'quick plan', 'surgical plan'.
---

# FLASHPLAN — Fast & Surgical Planning for Focused Tasks

> **MANDATORY**: First action when this skill loads — say "⚡ FLASHPLAN ENABLED!" so the user knows rapid surgical planning started.

<HARD-GATE>
PLANNING ONLY — DO NOT IMPLEMENT.
This is strictly an inline planning skill. Under NO circumstances should you:
1. Write, edit, or modify any project code or source files.
2. Scaffold execution directories or state (`.workflow/executions/`).
3. Automatically start executing Step 1 or trigger `hyperexecution`.

Your task ends completely when:
1. The plan is saved to `.workflow/plans/<SEQ>-YYYYMMDD-<kebab-case>.md` (e.g. `.workflow/plans/01-20260911-add-cli-flag.md`).
2. The results are presented to the user.

STOP IMMEDIATELY after outputting results. Wait for the user to review the plan and explicitly command you to execute it (e.g. via `/hyperexecution .workflow/plans/01-20260911-...`).
</HARD-GATE>

## WHAT THIS IS

**`flashplan`** is the agile, high-velocity sibling in the planning triad:
- **`flashplan`** &rarr; Small / focused tasks (1–2 files, localized bug fixes, small features, flags).
- **`superplan`** &rarr; Medium tasks (features, multi-file changes, API endpoints).
- **`hyperplan`** &rarr; Large / high-risk tasks (architecture, migrations, major subsystems).

Unlike generic out-of-the-box `/plan`, **`flashplan` is code-grounded, YAGNI-enforced, verification-bound, and disk-persisted**, without the overhead of spawning subagents (runs inline in ~3 seconds).

---

## CORE PRINCIPLES

1. **Zero Subagents (Instant Execution)**: Executes immediately in the main context. No committee, no debate latency.
2. **Ground Before You Plan**: Never hallucinate file paths or function names. Spend 5 seconds inspecting the actual code first.
3. **Shortest Working Diff (YAGNI)**: Enforce standard library and existing utility reuse. No new files or abstractions unless strictly required.
4. **Evidence-Bound Steps**: Every step must include an exact runnable verification command (tests, curl, or assertions).
5. **Interactive Scope Ceiling (3–5 Steps)**: If a plan requires >5 steps, trigger an interactive question to ask if the user wants to upgrade to `/superplan` or continue.

---

## SCOPE GUARDRAIL (INTERACTIVE UPGRADE)

`flashplan` is strictly calibrated for **small tasks (1–2 files, 3–5 steps)**.

If during codebase grounding or step formulation you find the task requires **>5 steps** or touches **>2 modules**:
- **DO NOT proceed blindly**. 
- **Prompt the user immediately** using `ask_question`:
  - **Question**: `"This task requires >5 steps, which exceeds the scope of flashplan. How would you like to proceed?"`
  - **Options**:
    1. `"(Recommended) Upgrade to /superplan — Launch the 2-agent Builder vs Red Team review for medium tasks."`
    2. `"Continue with flashplan anyway — Keep it inline and complete the plan."`
- If user selects upgrade: abort inline flashplan and trigger `/superplan`.
- If user selects continue: proceed and persist the plan.

---

## PHASE 0: CODEBASE GROUNDING (RAPID CHECK)

Before formulating the plan, perform a targeted inspection of the target file(s):
- Prioritize querying local MCP `call_mcp_tool(ServerName="codegraph", ToolName="codegraph_explore", Arguments={"query": "<target symbol/flow>", "projectPath": "<dir>"})` to retrieve verbatim source, call paths, and relevant imports in a single round trip.
- Bulk file reading via `read_multiple_files` is strictly banned in Phase 0 to preserve the ~3s SLA.
- If querying local LSP tools (`lsp_document_symbols`, `lsp_definition`), all line and character coordinates MUST be 0-indexed (`lsp_line = line - 1`), converting from 1-indexed editor/grep lines.
- If the project lacks a `.codegraph/` index or tools are unavailable, immediately fall back to `grep_search` + targeted `view_file` (preserving the ~3s SLA). NEVER run `codegraph init` autonomously.
- Verify existing tests or check scripts related to this area.

---

## PHASE 1: COMPOSE 3–5 ATOMIC STEPS

Formulate strictly 3 to 5 atomic steps (unless user explicitly approved continuing beyond 5 steps). Each step must contain:
- **Target File**: Exact relative or absolute path.
- **Action**: Exact function/line change (shortest working diff).
- **Verification**: Exact runnable command and expected outcome.

---

## PHASE 2: PERSISTENCE

Save the plan directly to the project's `.workflow/plans/` directory:
1. Inspect `.workflow/plans/` to determine the next two-digit sequential number prefix `<SEQ>` (e.g., `01`, `02`, ..., `15`).
2. Current date in `YYYYMMDD` format (e.g. `20260911`).
3. Descriptive kebab-case slug for the plan title.
4. Save the file as: `.workflow/plans/<SEQ>-YYYYMMDD-<kebab-case>.md` (e.g. `.workflow/plans/01-20260911-add-cli-flag.md`).
5. Format each step with checkboxes `[ ]`.

The plan is now saved. Do NOT execute it automatically. Wait for the user to invoke [`/hyperexecution`](../hyperexecution/SKILL.md).

---

## OUTPUT FORMAT

Present the plan concisely: (1) Grounding & Scope Check (target files, helpers reused, scope status), (2) Executable Plan (3–5 atomic steps formatted with checkboxes `- [ ] **Step N: [Action Title]**`, target file, change, and exact verification command), and (3) Persisted Plan File path (`.workflow/plans/<SEQ>-YYYYMMDD-<kebab-case>.md`, ready for `/hyperexecution`).
