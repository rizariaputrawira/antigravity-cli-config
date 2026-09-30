# Spec: `/to-spec` Skill — Specification Layer for the AGY Workflow

**Date:** 2026-09-30  
**Status:** Approved for planning  
**Triggered by:** Brainstorm session (Option 1 selected)

---

## Problem Statement

The AGY workflow has a clean `plan → execution` pipeline, but lacks a formal **specification stage** between
brainstorming and planning. After a brainstorm, conversations produce valuable design decisions, seam
sketches, and user stories that currently get flattened into the brainstorm spec or get lost before
planning begins. There is no way to synthesize that context into a structured, referenceable artifact
that planning skills can reliably consume — whether the conversation came from `/brainstorm`, a design
discussion, or raw chat.

---

## Solution

Introduce a `/to-spec` skill that synthesizes the current conversation context (brainstorm output,
design discussion, or raw chat) into a formal specification document saved at
`.workflow/specs/<SEQ>-YYYYMMDD-<kebab-case>-spec.md`. The skill does NOT re-interview the user —
it synthesizes what is already known.

Planning skills (`/flashplan`, `/superplan`, `/hyperplan`) gain auto-detection logic: they accept an
explicit spec or brainstorm path as an argument, and fall back to discovering the latest file in
`.workflow/specs/` when no path is given. The `/brainstorm` skill gains a transition prompt that
offers `/to-spec` as the natural next step.

---

## User Stories

1. As a developer who just ran `/brainstorm`, I want to run `/to-spec` immediately afterward so that the
   design decisions we discussed are captured in a structured spec I can review and commit.
2. As a developer in a regular chat session (no `/brainstorm`), I want to run `/to-spec` so that the
   feature we discussed gets synthesized into a spec without me having to re-explain everything.
3. As a developer, I want the spec to follow a consistent template (Problem, Solution, User Stories,
   Implementation Decisions, Testing Decisions, Out of Scope) so I always know where to find each type
   of information.
4. As a developer, I want the spec template to include AGY-specific sections (Settled Decisions ledger,
   Fog of War frontier) so architectural decisions are explicitly captured alongside open unknowns.
5. As a developer, I want to be able to run `/to-spec` and `/superplan` back-to-back so I can go from
   conversation → spec → plan without manual copy-paste of file paths.
6. As a developer, I want planning skills to automatically pick up the latest spec from `.workflow/specs/`
   when I don't explicitly pass a path, so there is zero friction when I follow the canonical pipeline.
7. As a developer, I want the spec to sketch the **testing seams** (the points in the code where behavior
   will be verified) and show me them before it writes the spec, so I can correct misunderstandings early.
8. As a developer, I want the spec file committed to git after it is written so it is tracked in history.
9. As a developer, I want the spec to explicitly state what is **out of scope** so that the implementation
   plan does not grow scope unintentionally.
10. As a developer, I want the `/brainstorm` skill to offer `/to-spec` as a transition step at the end of
    design, so the path from brainstorm to spec is always surfaced and never forgotten.
11. As a developer, I want planning skills to accept both a `.workflow/specs/` path and a `.workflow/brainstorm/`
    path as input, so I can also plan directly from a brainstorm doc if preferred.
12. As a developer, I want the `workflow-health-check` script to verify `.workflow/specs/` exists and flag
    any specs without corresponding plans, so the health check covers the full pipeline.
13. As a developer, I want `/to-spec` registered in `config/AGENTS.md` with triggers, so AGY routes to it
    automatically from natural language phrases like "create spec", "write a spec", "to-spec".
14. As a developer, I want `README.md` updated to document the full pipeline
    (`brainstorm → spec → plan → execution`) with the new stage included.
15. As a developer reading a spec, I want to see a **Fog of War frontier** section that explicitly lists
    still-open unknowns, so I know what is settled and what the plan should NOT over-specify.

---

## Implementation Decisions

### New: `config/skills/to-spec/SKILL.md`
- Trigger: `/to-spec`, `to-spec`, `write spec`, `create spec`, `synthesize spec`.
- **NO re-interview**: synthesizes purely from existing conversation context and any codebase exploration
  already done. If the codebase has not been explored, the skill does a quick targeted read to ground
  the spec in real module names.
- **Seam checkpoint**: before writing the spec, present the proposed testing seams (highest-level
  observable behavior points) to the user for confirmation. Wait for approval.
- **Spec template** (see template section below).
- **SEQ detection**: inspect `.workflow/specs/` for files matching `[0-9]{2}-*`, take the highest
  two-digit prefix + 1 (default `01` if empty).
- **Output path**: `.workflow/specs/<SEQ>-YYYYMMDD-<kebab-case>-spec.md`.
- **Post-write**: commit to git, then offer the transition:
  > "Spec saved to `.workflow/specs/<SEQ>-…-spec.md`. Ready to plan? Run `/superplan` (medium, 2–6 files)
  > or `/hyperplan` (large/adversarial). Planning skills will auto-detect this spec."

### Modified: `config/skills/brainstorm/SKILL.md`
- After the **User Review Gate** (where the user approves the brainstorm design doc), add a transition
  prompt offering `/to-spec` as the next natural step:
  > "Design approved. Want me to generate a formal spec now? Run `/to-spec` and I'll synthesize this
  > brainstorm into a structured spec (User Stories, Seams, Implementation Decisions, Out of Scope)
  > saved to `.workflow/specs/`."
- No other changes to brainstorm logic. The brainstorm doc itself continues to be saved to
  `.workflow/brainstorm/` as before.

### Modified: `config/skills/flashplan/SKILL.md`, `superplan/SKILL.md`, `hyperplan/SKILL.md`
- Add a **Context Resolution** block at the top of each skill's process section:
  1. If an explicit path argument is provided (`.workflow/specs/` or `.workflow/brainstorm/`), read that file.
  2. Else, auto-detect: look for the most recent file in `.workflow/specs/` (by filename SEQ/date prefix),
     then `.workflow/brainstorm/`, then fall back to active conversation context.
  3. Log which source was used: "📄 Planning from spec: `.workflow/specs/01-…-spec.md`"
- No other changes to planning skill logic.

### Modified: `scripts/workflow-health-check.sh`
- Add check for `.workflow/specs/` directory existence (warn if missing but not error).
- For each `*.md` file in `.workflow/specs/`, verify a corresponding plan exists in `.workflow/plans/`
  that references the same SEQ or name. Report as advisory (not a hard failure).

### Modified: `config/AGENTS.md`
- Add row to Skills table:
  ```
  | `to-spec` | '/to-spec', 'to-spec', 'write spec', 'create spec', 'synthesize spec' | Synthesize conversation or brainstorm into a structured spec at .workflow/specs/ |
  ```

### Modified: `README.md`
- Add a **Workflow Pipeline** section documenting the full canonical path:
  ```
  /brainstorm → /to-spec → /superplan or /hyperplan → /hyperexecution
  ```
  With callouts showing which steps are optional and which can be entered from chat directly.

---

## Spec Template (for `/to-spec` output)

```markdown
# Spec: <Title>

**Date:** YYYY-MM-DD
**Status:** Draft | Approved

## Problem Statement
…from the user's perspective…

## Solution
…from the user's perspective…

## User Stories
1. As a <actor>, I want <feature>, so that <benefit>
…(exhaustive list)…

## Testing Decisions (Seams)
- **Seam 1**: <module/interface> — <what behavior is verified here>
- Prefer existing seams; propose new ones only when unavoidable.
- Highest-level seam wins: test the observable outcome, not the internals.

## Implementation Decisions
- Modules built/modified (no file paths — they go stale)
- Interface changes
- Architectural choices and their rationale
- Schema or API contracts
- Specific interactions
- (If a prototype produced a decision-encoding snippet: inline it briefly, note it came from prototype)

## Settled Decisions & Answers
| Decision | Answer | Rationale |
|---|---|---|
| … | … | … |

## Fog of War (Open Unknowns)
> Things in scope that are not yet specifiable. The plan MUST NOT over-specify these.
- [ ] Unknown 1
- [ ] Unknown 2

## Out of Scope
- …explicitly listed items that will NOT be built…

## Further Notes
…anything else relevant…
```

---

## Testing Decisions (Seams for this feature itself)

- **Seam 1 — Skill file exists and is loadable**: After implementation, `cat config/skills/to-spec/SKILL.md`
  must exist and contain the trigger keywords `to-spec`, `write spec`, `create spec`.
- **Seam 2 — AGENTS.md registers the skill**: `grep 'to-spec' config/AGENTS.md` returns the table row.
- **Seam 3 — Spec output follows naming convention**: After a simulated `/to-spec` invocation, the output
  file matches `^[0-9]{2}-[0-9]{8}-.*-spec\.md$` in `.workflow/specs/`.
- **Seam 4 — Planning skills resolve latest spec**: Manual inspection of updated planning SKILL.md files
  confirms the Context Resolution block is present and documents the fallback chain.
- **Seam 5 — Health check covers specs dir**: `./scripts/workflow-health-check.sh --check` runs without
  errors after `.workflow/specs/` is created.

---

## Settled Decisions & Answers

| Decision | Answer | Rationale |
|---|---|---|
| Invocation style | Strict `/to-spec` only | User explicitly chose Matt Pocock's naming |
| Spec storage | `.workflow/specs/<SEQ>-YYYYMMDD-<name>-spec.md` | Separate from brainstorm; auto-detected by planners |
| Template | Enhanced AGY spec (Pocock core + Settled Decisions + Fog of War) | Best of both worlds |
| Brainstorm transition | Offer `/to-spec` after User Review Gate (not automatic) | Preserves human gate; respects PLAN-ONLY hard gate |
| Planner context resolution | Auto-detect latest `.workflow/specs/` → `.workflow/brainstorm/` → chat | Zero friction; still explicit when path provided |
| Re-interview | None — synthesize only | Pocock principle; avoids annoying the user |

---

## Fog of War (Open Unknowns)

> These are in scope but cannot be fully specified yet. The plan MUST NOT over-specify them.

- [ ] Whether the `to-spec` skill should also support being invoked with a specific brainstorm file path
  as an argument (e.g., `/to-spec .workflow/brainstorm/01-...md`) to constrain synthesis to that document.
  (Likely yes; resolve during implementation.)
- [ ] Exact wording for the brainstorm → spec transition prompt (will be tuned during implementation).

---

## Out of Scope

- Publishing specs to an external issue tracker (GitHub Issues, Linear). AGY workflow is local-file-first.
- A `/to-tickets` skill (Pocock's vertical-slice ticket generator). Not requested; remains future work.
- Auto-executing the plan after spec generation (hard gate must remain; user approval required).
- Modifying the spec template for non-engineering contexts (writing, content, etc.).
- Any changes to the `hyperexecution` or `orchestrate` skills.

---

## Further Notes

- Matt Pocock's `to-spec` skill uses an external issue tracker and domain glossary vocabulary loaded by
  `/setup-matt-pocock-skills`. The AGY variant is intentionally local-file-first and self-contained.
- The seam checkpoint (showing proposed testing seams before writing) is the most novel addition
  relative to the existing brainstorm → design doc flow; it catches misaligned mental models before the
  spec is committed.
- Workflow health check advisory (spec without plan) is a soft nudge, not a hard failure, to avoid
  penalizing specs that are mid-review.
