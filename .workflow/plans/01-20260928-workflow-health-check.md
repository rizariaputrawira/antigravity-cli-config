# 01-20260928-super-workflow-health-check.md

# Workflow Health Check & Auto-Repair (`/workflow-health-check`)

## Goal
Implement `/workflow-health-check` skill and automated migration/repair tool (`workflow-health-check.sh`) that:
1. Detects and auto-migrates old workflow directories (`.ar-wf`, `planning`, nested `brainstorm`, `executions/executions`, old `evidence`) to the new standard (`.workflow/plans`, `.workflow/brainstorm`, `.workflow/executions/runs/<id>`, `.workflow/executions/evidence`).
2. Patches obsolete path/skill references inside project plans, specs, and state files.
3. Audits and repairs skills in `~/.gemini/config/skills` and local workspaces (detecting deprecated `ar-*`, old `ultrawork`, broken frontmatter, missing permissions, and out-of-sync hooks).
4. Exposes clear CLI modes (`--check` for read-only audit, `--fix` for safe migration) and a first-class slash command skill `/workflow-health-check`.

---

## Tasks

- [x] **Step 1: Build the automated `workflow-health-check.sh` engine**
  - Create `scripts/workflow-health-check.sh` (executable, robust bash script).
  - Support `--workspace=<dir>`, `--check` (audit mode), `--fix` (migration mode), `--dry-run`.
  - Implement Section 1: Workflow directory migration (`.ar-wf` -> `.workflow`, `planning` -> `plans`, brainstorm un-nesting, `executions` -> `runs/<id>`, evidence path migration, `.gitignore` check).
  - Implement Section 2: Reference rewriting (updating `.ar-wf` and deprecated skill names in `.workflow/**/*.md`).
  - Implement Section 3: Skill health check and auto-repair (detecting legacy `ar-*`, `ultrawork`, syncing updated skills from repo if available, verifying frontmatter syntax, fixing executable permissions).
  - Target: `scripts/workflow-health-check.sh`
  - Verification: `bash -n scripts/workflow-health-check.sh && ./scripts/workflow-health-check.sh --check`

- [x] **Step 2: Create the `workflow-health-check` skill definition**
  - Create `config/skills/workflow-health-check/SKILL.md`.
  - Include triggers: `/workflow-health-check`, `workflow-health-check`, `wf-doctor`, `wf-repair`, `repair workflow`.
  - Document Audit Mode vs Fix Mode, step-by-step diagnostic tables, and migration rules.
  - Target: `config/skills/workflow-health-check/SKILL.md`
  - Verification: `test -f config/skills/workflow-health-check/SKILL.md && grep -q "name: workflow-health-check" config/skills/workflow-health-check/SKILL.md`

- [x] **Step 3: Update `config/AGENTS.md` and `README.md`**
  - Add `workflow-health-check` to the global skills table in `config/AGENTS.md`.
  - Add documentation and usage guide in `README.md`.
  - Target: `config/AGENTS.md`, `README.md`
  - Verification: `grep -q "workflow-health-check" config/AGENTS.md && grep -q "workflow-health-check" README.md`

- [x] **Step 4: End-to-end verification and regression testing**
  - Create a temporary legacy test fixture workspace with `.workflow/plans/01-old.md`, nested brainstorm, old execution state.
  - Run `./scripts/workflow-health-check.sh --workspace=<fixture> --check` and verify detection.
  - Run `./scripts/workflow-health-check.sh --workspace=<fixture> --fix` and verify migration to `.workflow/plans/`, `.workflow/brainstorm/`, `.workflow/executions/runs/`.
  - Run `./install.sh --dry-run` to ensure install passes cleanly.
  - Cleanup temporary test fixture.
  - Target: Verification report in `.workflow/executions/evidence/01-20260928-workflow-health-check/task-4/report.txt`
  - Verification: `exit code 0` on all checks.
