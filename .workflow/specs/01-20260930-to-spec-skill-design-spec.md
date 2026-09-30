# Spec: `/to-spec` Skill — Specification Layer for the AGY Workflow

**Date:** 2026-09-30  
**Status:** Approved for planning  
**Triggered by:** Brainstorm session (Option 1 selected)

---

## Problem Statement

The AGY workflow has a clean `plan → execution` pipeline, but lacks a formal **specification stage**
between brainstorming and planning. Conversations produce valuable design decisions and user stories
that currently get flattened into the brainstorm doc or lost before planning begins. There is no way
to synthesize that context into a structured, referenceable artifact that planning skills can consume —
whether the conversation came from `/brainstorm`, a design discussion, or raw chat.

---

## Solution

Introduce a `/to-spec` skill that synthesizes the current conversation context into a formal
specification document saved at `.workflow/specs/<SEQ>-YYYYMMDD-<kebab-case>-spec.md`. The skill
does NOT re-interview the user — it synthesizes what is already known.

Planning skills (`/flashplan`, `/superplan`, `/hyperplan`) accept an explicit spec or brainstorm path
as an argument; when none is given they fall back to active conversation context. The `/brainstorm`
skill gains a transition prompt offering `/to-spec` as the natural next step after design approval.

---

## User Stories

1. As a developer after `/brainstorm` or a chat design session, I want to run `/to-spec` so that what
   we discussed is captured in a structured spec I can review, commit, and pass to a planning skill.
2. As a developer, I want the spec to follow a consistent template (Problem, Solution, User Stories,
   Implementation Decisions, Testing Seams, Out of Scope) so I always know where to find each type
   of information.
3. As a developer, I want to run `/superplan .workflow/specs/01-…-spec.md` immediately after `/to-spec`
   so I can go from conversation → spec → plan with a single explicit path and zero ambiguity.
4. As a developer, I want the spec to include **testing seams** (highest-level observable behavior
   points) in the output, so the implementation plan knows exactly where to assert correctness.
5. As a developer, I want the spec file committed to git after it is written so it is tracked in history.
6. As a developer, I want the spec to explicitly state what is **out of scope** so scope creep is
   visible and named.
7. As a developer, I want the `/brainstorm` skill to surface `/to-spec` as a transition step after
   design approval, so the path from brainstorm to spec is always visible.
8. As a developer, I want `/to-spec` registered in `config/AGENTS.md` with triggers so AGY routes to
   it from natural phrases like "write spec", "create spec", "to-spec".
9. As a developer, I want `README.md` updated to document the full pipeline
   (`brainstorm → spec → plan → execution`) with this new stage included.

---

## Implementation Decisions

### New: `config/skills/to-spec/SKILL.md`
- Triggers: `/to-spec`, `to-spec`, `write spec`, `create spec`.
- **No re-interview**: synthesizes from existing conversation context. If the codebase has not been
  explored, does a quick targeted read to ground the spec in real module names.
- **Seams inline**: testing seams are included as a section of the output spec, not a blocking
  checkpoint before writing. The user reviews the committed spec and can request changes.
- **SEQ detection**: inspect `.workflow/specs/` for files matching `[0-9]{2}-*`, take highest + 1
  (default `01` if empty).
- **Output path**: `.workflow/specs/<SEQ>-YYYYMMDD-<kebab-case>-spec.md`.
- **Post-write**: commit to git, then surface the transition:
  > "Spec saved. Pass it to a planning skill: `/superplan .workflow/specs/<SEQ>-…-spec.md`"

### Modified: `config/skills/brainstorm/SKILL.md`
- After the **User Review Gate**, add one transition line:
  > "Design approved. Run `/to-spec` to synthesize this into a formal spec before planning."
- No other changes.

### Modified: `config/skills/flashplan/SKILL.md`, `superplan/SKILL.md`, `hyperplan/SKILL.md`
- Add one **Context Resolution** line at the top of each skill's process section:
  > "If a spec or brainstorm path was passed as an argument, read it first. Otherwise plan from active
  > conversation context."
- No other changes to planning skill logic.

### Modified: `config/AGENTS.md`
- Add row to Skills table:
  ```
  | `to-spec` | '/to-spec', 'to-spec', 'write spec', 'create spec' | Synthesize conversation or brainstorm into a structured spec at .workflow/specs/ |
  ```

### Modified: `README.md`
- Add one paragraph to the Workflow section documenting the full canonical path:
  ```
  /brainstorm → /to-spec → /superplan or /hyperplan → /hyperexecution
  ```

---

## Testing Decisions (Seams for this feature)

- **Seam 1 — Skill file exists**: `config/skills/to-spec/SKILL.md` exists and contains trigger
  keywords `to-spec`, `write spec`, `create spec`.
- **Seam 2 — AGENTS.md registers the skill**: `grep 'to-spec' config/AGENTS.md` returns the row.
- **Seam 3 — Spec naming convention**: output file matches `^[0-9]{2}-[0-9]{8}-.*-spec\.md$` in
  `.workflow/specs/`.
- **Seam 4 — Planning skills have context resolution line**: grep confirms the one-line block is
  present in flashplan, superplan, and hyperplan SKILL.md files.

---

## Settled Decisions & Answers

| Decision | Answer | Rationale |
|---|---|---|
| Invocation style | Strict `/to-spec` only | User explicitly chose Matt Pocock's naming |
| Spec storage | `.workflow/specs/<SEQ>-YYYYMMDD-<name>-spec.md` | Separate from brainstorm; explicit path for planners |
| Template | Pocock core + AGY Settled Decisions table (ad-hoc when needed) | Fog of War belongs in Out of Scope, not template |
| Brainstorm transition | One-line offer after User Review Gate | Minimal friction; preserves human gate |
| Planner context resolution | Explicit path arg or active conversation context | No 3-tier auto-detect; explicit is simpler |
| Seam checkpoint | Inline in spec output, not a blocking round-trip | Less friction; user reviews committed spec |
| Re-interview | None — synthesize only | Pocock principle |

---

## Out of Scope

- Publishing specs to an external issue tracker (GitHub Issues, Linear). AGY is local-file-first.
- A `/to-tickets` skill. Not requested; remains future work.
- Auto-executing the plan after spec generation. Hard gate must remain.
- Health-check advisory for specs-without-plans. Advisory-only checks that never fail are noise.
- Any changes to `hyperexecution` or `orchestrate` skills.

---

## Further Notes

- Matt Pocock's `to-spec` requires an external issue tracker setup via `/setup-matt-pocock-skills`.
  The AGY variant is intentionally local-file-first and self-contained.
- The spec template lives in `config/skills/to-spec/SKILL.md`, not in this design doc.
