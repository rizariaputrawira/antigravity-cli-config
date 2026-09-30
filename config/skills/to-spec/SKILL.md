---
name: to-spec
description: >-
  Synthesizes the current conversation or a brainstorm document into a formal specification
  file saved at .workflow/specs/<SEQ>-YYYYMMDD-<kebab-case>-spec.md. No re-interview —
  works from what is already known. Commit-ready output with inline testing seams. Use after
  /brainstorm approval or any design conversation to create a referenceable spec before
  planning. Triggers: '/to-spec', 'to-spec', 'write spec', 'create spec'.
---

# TO-SPEC — Synthesize Conversation Into a Formal Spec

> **MANDATORY**: First action when this skill loads — say "📋 TO-SPEC ENABLED — synthesizing spec from context." so the user knows spec generation started.

<HARD-GATE>
SPEC WRITING ONLY — DO NOT PLAN OR IMPLEMENT.
Under NO circumstances should you:
1. Invoke /flashplan, /superplan, /hyperplan, or /hyperexecution.
2. Write, edit, or modify any project source files.

Your task ends completely when:
1. The spec is saved to `.workflow/specs/<SEQ>-YYYYMMDD-<kebab-case>-spec.md`.
2. The file is committed to git.
3. The transition prompt is shown to the user.

STOP IMMEDIATELY after the transition prompt.
</HARD-GATE>

## PHASE 0: CONTEXT GROUNDING

- **If a path argument was given** (e.g. `/to-spec .workflow/brainstorm/01-…-design.md`): read that file first as the primary context source.
- **If no argument was given**: synthesize directly from the active conversation context. Do NOT re-interview the user.
- **Empty context guard**: If the conversation history has no design content (no prior brainstorm, no requirements discussed), STOP immediately and say:
  > "I don't have enough conversation context to synthesize a spec. Run `/brainstorm` first, or paste the design you want captured."
- If real module names or file paths are referenced but not yet grounded, do a quick targeted read (`grep_search` or `view_file` on the specific files mentioned) to confirm names. Do NOT perform an unbounded directory scan.

## PHASE 1: SPEC COMPOSITION

Fill the following template. Every section is mandatory; write "None" for sections with no content rather than omitting them.

```markdown
# Spec: <Title>

**Date:** YYYY-MM-DD
**Status:** Draft
**Source:** <"Brainstorm session" | "Design conversation" | path to source doc>

---

## Problem Statement

<1–3 sentences: what problem does this solve and for whom, from the user's perspective?>

---

## Solution

<Concise description of the proposed solution from the user's perspective. No implementation details here — just the what and why.>

---

## User Stories

<Numbered list of user stories: "1. As a <role>, I want <goal> so that <reason>.">

---

## Implementation Decisions

<Numbered or bulleted list of concrete decisions already settled: which modules change, which APIs are added, which patterns are used. Avoid fragile code snippets unless encoding schemas/state machines.>

---

## Testing Seams

<Numbered list of the highest-level observable behavior points (what to assert, not how to implement the test). Prefer existing seams; highest-level seam wins.>

---

## Out of Scope

<Explicit list of what this spec does NOT cover. "None" if truly none. Open unknowns also belong here.>

---

## Settled Decisions & Answers

| Decision | Answer | Rationale |
|---|---|---|
| <decision> | <answer> | <one-line reason> |
```

## PHASE 2: PERSISTENCE & COMMIT

1. Run `mkdir -p .workflow/specs` to ensure the directory exists before any SEQ detection.
2. Inspect `.workflow/specs/` for files matching `[0-9]{2}-*`; find the highest two-digit sequence and increment by 1 (default `01` if empty).
   *Note: SEQ `01` may already be taken if an existing spec exists; increment accordingly.*
3. Save the file as `.workflow/specs/<SEQ>-YYYYMMDD-<kebab-case>-spec.md` (strictly lowercase kebab-case).
4. Run `git add .workflow/specs/<filename> && git commit -m "docs(specs): add <kebab-case> spec"`.

## PHASE 3: TRANSITION PROMPT

After committing, surface exactly:

> "📋 Spec saved to `.workflow/specs/<SEQ>-YYYYMMDD-<kebab-case>-spec.md` and committed.
>
> Pass it to a planning skill:
> - `/superplan .workflow/specs/<SEQ>-…-spec.md` — for medium tasks (2–6 files)
> - `/hyperplan .workflow/specs/<SEQ>-…-spec.md` — for large/adversarial architectures
> - `/flashplan .workflow/specs/<SEQ>-…-spec.md` — for small focused tasks (1–2 files)"

STOP. Do not invoke any planning skill automatically.
