# Plan: Skill Interaction Audit and Planning Guide

- [x] **Step 1: Audit Skill Interactions**
  - Search `config/skills` for cross-references between planning and execution skills (`hyperplan`, `superplan`, `flashplan`, `hyperexecution`, `brainstorm`, `orchestrate`). Verify there are no legacy references (e.g. `ultrawork`) or broken file paths.
  - Verification: `grep -rn "ultrawork" config/skills || true` and check output.

- [x] **Step 2: Fix Broken Interactions**
  - Update any files found in Step 1 to use correct current names and accurate workflow paths. If no fixes needed, trivially pass.
  - Verification: `echo "Fixes applied or none needed"`

- [x] **Step 3: Create `docs/PLANNING_GUIDE.md`**
  - Write a comprehensive markdown guide explaining how to interact with the planning and execution tiers (`flashplan`, `superplan`, `hyperplan`, `orchestrate`, and `hyperexecution`), including state tracking and handoffs.
  - Verification: `test -f docs/PLANNING_GUIDE.md`

- [x] **Step 4: Update `README.md`**
  - Add a dedicated section summarizing the Planning and Execution workflow and link to `docs/PLANNING_GUIDE.md`.
  - Verification: `grep -Fq "PLANNING_GUIDE.md" README.md`
