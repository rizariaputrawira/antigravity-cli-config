# Plan: Implement `/to-spec` Skill — Specification Layer for AGY Workflow

**Spec**: `.workflow/specs/01-20260930-to-spec-skill-design-spec.md`  
**Tier**: superplan (7 files, 6 steps)  
**Date**: 2026-09-30

---

- [x] **Step 1: Create `config/skills/to-spec/SKILL.md`**

  Create the new skill file following existing YAML frontmatter + PHASE conventions.

  **Key guards to include (from Red Team):**
  - **Empty context guard** in Phase 0: if conversation has no design content, stop and say "I don't have enough conversation context to synthesize a spec. Run `/brainstorm` first, or paste the design you want captured." Do NOT produce a spec from nothing.
  - **`mkdir -p .workflow/specs`** must be the first filesystem operation in Phase 2 before SEQ detection.
  - **Custom HARD-GATE** (not a copy of the planning pattern): "SPEC WRITING ONLY — do NOT invoke /flashplan, /superplan, /hyperplan, or /hyperexecution."
  - **No Fog of War section** in the output template — unknowns go into Out of Scope.
  - **Settled Decisions table** is a mandatory section in the template (not ad-hoc).

  **Content to write** (YAML frontmatter → PHASE 0 → PHASE 1 → PHASE 2 → PHASE 3):

  ```
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

  > **MANDATORY**: First action — say "📋 TO-SPEC ENABLED — synthesizing spec from context."

  <HARD-GATE>
  SPEC WRITING ONLY — DO NOT PLAN OR IMPLEMENT.
  Do NOT invoke /flashplan, /superplan, /hyperplan, or /hyperexecution.
  Do NOT write or edit any project source files.
  Stop after: spec saved + git commit + transition prompt shown.
  </HARD-GATE>

  ## PHASE 0: CONTEXT GROUNDING

  - If a path argument was given (e.g. `/to-spec .workflow/brainstorm/01-…-design.md`):
    read that file first as the primary context source.
  - If no argument: synthesize from active conversation context. Do NOT re-interview the user.
  - **Empty context guard**: if the conversation has no design content (no brainstorm, no
    requirements discussed), stop immediately and say:
    > "I don't have enough conversation context to synthesize a spec. Run `/brainstorm`
    > first, or paste the design you want captured."
  - If file paths or module names are referenced but ungrounded, do a quick targeted read
    (`grep_search` or `view_file`) on those specific files only. No full directory scans.

  ## PHASE 1: SPEC COMPOSITION

  Write using this template. Every section is mandatory; write "None" rather than omitting.

  ---
  # Spec: <Title>
  **Date:** YYYY-MM-DD  **Status:** Draft
  **Source:** <"Brainstorm session" | "Design conversation" | path to source doc>

  ## Problem Statement
  <1–3 sentences from the user's perspective>

  ## Solution
  <Concise what/why — no implementation details>

  ## User Stories
  1. As a <role>, I want <goal> so that <reason>.

  ## Implementation Decisions
  <Settled decisions: which files change, which APIs, which patterns. Cite file paths.>

  ## Testing Seams
  1. <Highest-level observable behavior to assert — not how to test it, what to test>

  ## Out of Scope
  <Explicit list. "None" if truly none.>

  ## Settled Decisions & Answers
  | Decision | Answer | Rationale |
  |---|---|---|
  | <decision> | <answer> | <one-line reason> |
  ---

  ## PHASE 2: PERSISTENCE & COMMIT

  1. `mkdir -p .workflow/specs` — must be first, before any SEQ detection.
  2. Inspect `.workflow/specs/` for files matching `[0-9]{2}-*`; increment the highest
     two-digit prefix by 1 (default `01` if none found).
     **Note**: SEQ `01` is taken by the bootstrap design spec (`01-20260930-to-spec-skill-design-spec.md`).
     First user-generated spec will be `02`.
  3. Write to `.workflow/specs/<SEQ>-YYYYMMDD-<kebab-case>-spec.md`.
  4. `git add .workflow/specs/<filename> && git commit -m "docs(specs): add <kebab-case> spec"`

  ## PHASE 3: TRANSITION PROMPT

  > "📋 Spec saved to `.workflow/specs/<SEQ>-…-spec.md` and committed.
  >
  > Pass it to a planning skill:
  > - `/superplan .workflow/specs/<SEQ>-…-spec.md` — medium tasks (2–6 files)
  > - `/hyperplan .workflow/specs/<SEQ>-…-spec.md` — large/adversarial architectures
  > - `/flashplan .workflow/specs/<SEQ>-…-spec.md` — small focused tasks (1–2 files)"

  STOP. Do not invoke any planning skill automatically.
  ```

  **Also**: copy skill to global install location:
  `cp -r config/skills/to-spec ~/.gemini/config/skills/to-spec`

  **Verification**:
  ```bash
  test -f config/skills/to-spec/SKILL.md && echo "✅ file exists" || echo "❌ missing"
  grep -E 'to-spec|write spec|create spec' config/skills/to-spec/SKILL.md
  test -d ~/.gemini/config/skills/to-spec && echo "✅ globally installed" || echo "❌ not installed"
  ```

---

- [x] **Step 2: Edit `config/skills/brainstorm/SKILL.md` — add `/to-spec` transition**

  **Location**: After line 216 (`Wait for the user's response. Proceed only once approved.`),
  insert before the existing `**Transition to Implementation Planning:**` paragraph (line 218).

  **Insert**:
  ```markdown

  > 💡 **Optional next step**: Run `/to-spec` to synthesize the approved design into a formal,
  > referenceable spec at `.workflow/specs/` before planning.
  ```

  **Verification**:
  ```bash
  grep -n 'to-spec' config/skills/brainstorm/SKILL.md
  # Expected: line ~217 with the transition offer
  ```

---

- [x] **Step 3: Edit flashplan + superplan + hyperplan — add Context Resolution line (one pass each)**

  **flashplan** (`config/skills/flashplan/SKILL.md`):
  - Location: After line 63 (the "Before formulating the plan, perform a targeted inspection..." sentence)
  - Insert as first bullet under PHASE 0 (before the codegraph query bullet):
    ```markdown
    - **Context Resolution**: If a spec or brainstorm path was passed as an argument
      (e.g. `/flashplan .workflow/specs/01-…-spec.md`), read it first.
      Otherwise plan from active conversation context.
    ```

  **superplan** (`config/skills/superplan/SKILL.md`):
  - Location: Append to line 61 (end of PHASE 0 paragraph) as a second sentence:
    ```markdown
    If a spec or brainstorm path was passed as an argument
    (e.g. `/superplan .workflow/specs/01-…-spec.md`), read it first to ground the task;
    otherwise use active conversation context.
    ```

  **hyperplan** (`config/skills/hyperplan/SKILL.md`):
  - Location: Append to line 38 (end of PHASE 0 paragraph) as a second sentence:
    ```markdown
    If a spec or brainstorm path was passed as an argument
    (e.g. `/hyperplan .workflow/specs/01-…-spec.md`), read it first;
    otherwise use active conversation context.
    ```

  **Verification**:
  ```bash
  grep -n 'Context Resolution\|spec.*argument\|passed as an arg' \
    config/skills/flashplan/SKILL.md \
    config/skills/superplan/SKILL.md \
    config/skills/hyperplan/SKILL.md
  # Expected: one match per file
  ```

---

- [x] **Step 4: Edit `config/AGENTS.md` — add `to-spec` row + storage bullet**

  **Edit 1 — Skills table** (after line 27, last row `workflow-health-check`):
  ```markdown
  | `to-spec` | '/to-spec', 'to-spec', 'write spec', 'create spec' | Synthesize conversation or brainstorm into a structured spec at `.workflow/specs/` |
  ```

  **Edit 2 — Workflow Storage section** (after the `Brainstorm Specs` bullet, line ~33):
  ```markdown
  - **Specs**: `.workflow/specs/<SEQ>-YYYYMMDD-<kebab-case>-spec.md`
  ```

  Also sync to global:
  `cp config/AGENTS.md ~/.gemini/config/AGENTS.md`

  **Verification**:
  ```bash
  grep 'to-spec' config/AGENTS.md    # Skills table row
  grep 'specs' config/AGENTS.md      # Storage bullet
  grep 'to-spec' ~/.gemini/config/AGENTS.md  # Global sync
  ```

---

- [x] **Step 5: Edit `README.md` — add pipeline paragraph + update skill count**

  **Edit 1 — Pipeline paragraph** (after line 101, before `## 🩺 Workflow Health Check`):
  ```markdown

  The full canonical pipeline is: **`/brainstorm`** → **`/to-spec`** → **`/superplan`** or
  **`/hyperplan`** → **`/hyperexecution`**. After a brainstorm session, run `/to-spec` to
  crystallize the approved design into a structured spec at `.workflow/specs/`; then pass
  the spec path directly to a planning skill
  (e.g. `/superplan .workflow/specs/01-…-spec.md`). Each stage is optional — you can also
  plan directly from chat context without a prior brainstorm or spec.
  ```

  **Edit 2 — Skill count** (line 7 or wherever "29 Custom Skills" appears):
  - Change `29` → `30`

  **Verification**:
  ```bash
  grep -n 'to-spec\|pipeline\|brainstorm.*spec.*plan' README.md | head -5
  grep 'Custom Skills' README.md  # Should now show 30
  ```

---

- [x] **Step 6: Commit all changes + verify full installation**

  ```bash
  git add config/skills/to-spec/ \
          config/skills/brainstorm/SKILL.md \
          config/skills/flashplan/SKILL.md \
          config/skills/superplan/SKILL.md \
          config/skills/hyperplan/SKILL.md \
          config/AGENTS.md \
          README.md
  git commit -m "feat(skills): add /to-spec skill — specification layer for AGY workflow"
  ```

  **Full end-to-end verification**:
  ```bash
  # Seam 1: Skill file exists with triggers
  test -f config/skills/to-spec/SKILL.md && grep -qE 'to-spec|write spec|create spec' config/skills/to-spec/SKILL.md && echo "✅ Seam 1 PASS"

  # Seam 2: AGENTS.md row present
  grep -q 'to-spec' config/AGENTS.md && echo "✅ Seam 2 PASS"

  # Seam 3: Planning skills have Context Resolution
  grep -q 'Context Resolution\|passed as an argument' config/skills/flashplan/SKILL.md && \
  grep -q 'passed as an argument' config/skills/superplan/SKILL.md && \
  grep -q 'passed as an argument' config/skills/hyperplan/SKILL.md && echo "✅ Seam 3 PASS"

  # Seam 4: brainstorm has /to-spec transition
  grep -q 'to-spec' config/skills/brainstorm/SKILL.md && echo "✅ Seam 4 PASS"

  # Seam 5: Global deployment
  test -f ~/.gemini/config/skills/to-spec/SKILL.md && \
  grep -q 'to-spec' ~/.gemini/config/AGENTS.md && echo "✅ Seam 5 PASS"

  # Seam 6: .workflow/specs/ dir exists and is tracked
  test -d .workflow/specs && echo "✅ Seam 6 PASS"
  ```
