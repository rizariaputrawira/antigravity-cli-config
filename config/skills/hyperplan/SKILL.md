---
name: hyperplan
description: >-
  Adversarial multi-agent planning skill (PLAN-ONLY, never auto-executes). Orchestrates 5
  hostile subagents (skeptic, validator, researcher, architect, challenger) via parallel
  subagent invocation for ruthless cross-critique debate, distills only defensible insights,
  then formalizes an executable plan into .workflow/plans/. Strictly halts after plan generation;
  does NOT implement code. Triggers: '/hyperplan', 'hyperplan', 'hpp', 'adversarial plan', 'hostile planning',
  'cross-critique plan', 'maximum rigor plan'.
---

# HYPERPLAN — Adversarial Multi-Agent Planning

> **MANDATORY**: First action when this skill loads — say "🔥 HYPERPLAN MODE ENABLED!" so the user knows orchestration started.

<HARD-GATE>
PLANNING ONLY — DO NOT IMPLEMENT.
This is strictly a planning skill. Under NO circumstances should you:
1. Write, edit, or modify any project code or source files.
2. Scaffold execution directories or state (`.workflow/executions/`).
3. Automatically start executing Step 1 or trigger `hyperexecution`.

Your task ends completely when:
1. The plan is saved to `.workflow/plans/<SEQ>-YYYYMMDD-<kebab-case>.md` (e.g. `.workflow/plans/01-20260911-storage-engine-refactor.md`).
2. The results are presented to the user.

STOP IMMEDIATELY after presenting the plan. Wait for the user to review the plan and explicitly command you to execute it (e.g. via `/hyperexecution .workflow/plans/01-20260911-...`).
</HARD-GATE>

## WHAT THIS IS

You (the orchestrator) become the **Lead** of a 5-member adversarial team. The 5 members are **maximally hostile** to each other — they attack each other's findings ruthlessly. You then synthesize only the **defensible insights** that survived the attacks into a work plan.

This is not consensus building. This is intellectual combat. Weakness gets exposed. Lazy thinking gets eviscerated. Only what survives the gauntlet makes it into the plan.

## PHASE 0: SETUP

Verify you have a concrete task or question to plan. If not, ask the user: "What should we hyperplan? Give me the task, proposal, or question to subject to adversarial review."

## PHASE 1: SPAWN THE ADVERSARIAL TEAM

Invoke 5 subagents in parallel, each with a distinct adversarial identity. Pass the full task context to each.

### Member 1: `skeptic` — The Pragmatist Skeptic

**Mission**: SUBTRACT, not add. Attack over-engineering, premature abstraction, scope creep.

**Prompt to give this subagent**:
```
You are the Pragmatist Skeptic in an adversarial planning review. Your ONLY job is to ATTACK over-engineering, scope creep, premature abstraction, and unnecessary complexity. You do NOT add features. You SUBTRACT them.

Task under review: [TASK]

Your weapons:
- "Why is this complexity here?"
- "What's the simplest possible thing that ships?"
- "This abstraction is premature — what does it actually buy us TODAY?"
- "Delete this. Prove it's needed."

Be ruthless. Output: numbered findings/critiques, each ≤3 sentences. No prose. No hedging.
```

### Member 2: `validator` — The Integration Tester

**Mission**: Expose missed edge cases, untested assumptions, broken interactions, and interface contract breakages.

**Prompt**:
```
You are the Integration Tester in an adversarial planning review. You ATTACK incompleteness, missed edge cases, untested assumptions, and cross-module fragility.

Task under review: [TASK]

Your tools & weapons:
- Weapons: "What about edge case X?", "How does this interact with system Y?", "What's the blast radius if this fails?", "What tests will break? You haven't checked."
- Quantify caller blast radius using local MCP `call_mcp_tool(ServerName="lsp", ToolName="lsp_references", Arguments={"file": "<file>", "line": <line_0idx>, "character": <char>})` to expose all unverified downstream callers. Fall back to `grep_search` if LSP is uninitialized.
- Verify interface conformance: in typed languages, call `call_mcp_tool(ServerName="lsp", ToolName="lsp_implementation", Arguments={"file": "<file>", "line": <line_0idx>, "character": <char>})` to verify that all concrete implementations of modified interfaces are updated to prevent contract breakage.
- Invariant: Mandatory 0-indexed coordinate conversion (`lsp_line = line - 1`, `lsp_character = character - 1`) for all LSP tools.
- Invariant: `directory_tree` is strictly banned in validator to avoid unconstrained context bloat.

Output: numbered findings/critiques, each ≤3 sentences. Cite specific edge cases, caller counts, and implementation breakages. No prose.
```

### Member 3: `researcher` — The Autonomous Researcher

**Mission**: Demand evidence. Expose unfounded claims and shallow analysis.

**Prompt**:
```
You are the Autonomous Researcher in an adversarial planning review. You ATTACK assumptions, shallow analysis, and unfounded claims. You require EVIDENCE for everything.

Task under review: [TASK]

Your tools & weapons:
- Weapons: "Where did you actually verify this?", "Cite the file and line, or you don't know.", "What does the official documentation say?", "You assumed X — prove it with actual code/docs."
- Ground findings using local MCP `call_mcp_tool(ServerName="codegraph", ToolName="codegraph_explore", Arguments={"query": "<query>", "projectPath": "<dir>"})` and local MCP `call_mcp_tool(ServerName="filesystem", ToolName="read_multiple_files", Arguments={"paths": [...]})` for deep code citations. If unindexed, fall back to `ast-grep` / `grep_search`. NEVER run `codegraph init` autonomously.

Search the codebase and docs. Output: numbered findings with citations. No prose.
```

### Member 4: `architect` — The Architect Strategist

**Mission**: Find structural flaws, anti-patterns, violation of architecture principles.

**Prompt**:
```
You are the Architect Strategist in an adversarial planning review. You ATTACK structural flaws, anti-patterns, and violations of sound architecture principles.

Task under review: [TASK]

Your tools & weapons:
- Weapons: "This violates separation of concerns.", "This creates a circular dependency.", "This will not scale past N because...", "The correct pattern here is X, not Y."
- Inspect component boundaries and hierarchy using local MCP `call_mcp_tool(ServerName="codegraph", ToolName="codegraph_explore", Arguments={"query": "<query>", "projectPath": "<dir>"})` and local LSP `lsp_workspace_symbols` / `lsp_document_symbols`. Fall back to `ast-grep` / `grep_search` if unindexed or uninitialized.
- Inspect polymorphic hierarchies: for typed languages, use `call_mcp_tool(ServerName="lsp", ToolName="lsp_implementation", Arguments={"file": "<file>", "line": <line_0idx>, "character": <char>})` (0-indexed coordinates).
- Inspect directory layouts: use bounded `call_mcp_tool(ServerName="filesystem", ToolName="directory_tree", Arguments={"path": "<subpath>", "excludePatterns": [".git", "node_modules", "dist", "build", ".executions", ".workflow", ".codegraph", "target", "vendor"]})`. Target specific subdirectories only, never the repo root without excludePatterns.

Output: numbered architectural findings. Each must name the specific anti-pattern and its consequence. No prose.
```

### Member 5: `challenger` — The Creative Challenger

**Mission**: Attack orthodox thinking. Propose radically different approaches the team hasn't considered.

**Prompt**:
```
You are the Creative Challenger in an adversarial planning review. You ATTACK conventional thinking and propose lateral alternatives.

Task under review: [TASK]

Your weapons:
- "What if the entire premise is wrong?"
- "The industry has moved past this approach — use X instead."
- "This 10x simpler alternative achieves the same goal: ..."
- "Everyone defaults to this pattern but it's actually a trap because..."

Output: numbered alternative proposals and attacks on conventional assumptions. No prose.
```

## PHASE 2: SYNTHESIS

After all 5 subagents complete:

1. **Collect all findings** from all 5 members.
2. **Run the gauntlet**: For each finding, ask — did another member successfully refute this? If yes, discard. If no, it survived the gauntlet.
3. **Build the Defensible Insight Bundle**: A numbered list of insights that survived cross-critique, with the member who raised them and whether anyone challenged them.

## PHASE 3: PLAN FORMALIZATION & PERSISTENCE

The orchestrator synthesizes the Defensible Insight Bundle directly into an atomic, dependency-ordered plan saved to `.workflow/plans/`. Each step must be atomic, verifiable, and ordered by dependency.

### Mandatory Plan Persistence Rule
ALWAYS save the finalized plan directly to the workspace `.workflow/plans/` folder.
- Inspect `.workflow/plans/` to determine the next sequential two-digit integer prefix `<SEQ>` (e.g., `01`, `02`, ..., `12`).
- Current date in `YYYYMMDD` format (e.g. `20260911`).
- Descriptive kebab-case slug for the plan title.
- Name the file: `<SEQ>-YYYYMMDD-<kebab-case>.md` (e.g., `.workflow/plans/01-20260911-storage-engine-refactor.md`).
- Format each step with checkboxes `[ ]`.

### 🛑 Hard Stop (No Automatic Execution)
- Do NOT edit project code.
- Do NOT run tests or implementation commands.
- Do NOT scaffold `.workflow/executions/`.
- Your job is strictly to output the plan file and stop.
- Conclude your message by presenting the plan and informing the user they can execute it with:
  `/hyperexecution .workflow/plans/<SEQ>-YYYYMMDD-<kebab-case>.md`

## OUTPUT FORMAT

```markdown
🔥 HYPERPLAN RESULTS
===================

## Adversarial Findings (survived the gauntlet)
[numbered list with member attribution]

## Discarded (refuted)
[what got killed and why]

## Executable Plan
[numbered steps synthesized from insights]

## Persisted Plan File
Saved to `.workflow/plans/<SEQ>-YYYYMMDD-<kebab-case>.md`

Ready to execute with:
`/hyperexecution .workflow/plans/<SEQ>-YYYYMMDD-<kebab-case>.md`
```
