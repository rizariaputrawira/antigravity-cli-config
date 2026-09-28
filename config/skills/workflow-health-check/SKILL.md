---
name: workflow-health-check
description: >-
  Diagnoses and heals workspace workflow directories (.ar-wf -> .workflow, planning -> plans,
  brainstorm un-nesting, runs/<plan-id>, evidence preservation) and repairs broken, deprecated,
  or out-of-sync skills. Triggers: '/workflow-health-check', 'workflow-health-check', 'wf-doctor',
  'wf-repair', 'repair workflow'.
---

# Workflow Health Check & Auto-Repair (`/workflow-health-check`)

Provides unified workspace diagnostic and healing capabilities. When moving across devices, switching between repositories, or upgrading older projects, `/workflow-health-check` audits the active environment and brings all directories, references, and skills into full compliance with the latest Antigravity conventions.

---

## Capabilities & Diagnostic Matrix

| Area | What It Checks | What It Repairs (`--fix`) |
|---|---|---|
| **Workflow Root** | Legacy `.ar-wf/` directory | Moves contents safely to `.workflow/` |
| **Plans Directory** | Legacy `.workflow/planning/` | Renames to canonical `.workflow/plans/` |
| **Brainstorm Specs** | Nested in `planning/` or `plans/` | Relocates to peer directory `.workflow/brainstorm/` |
| **Execution Runs** | Legacy `.workflow/hyper-execution/` or nested `executions/executions/` | Restructures state to `.workflow/executions/runs/<plan-id>/` |
| **Evidence Store** | Legacy evidence paths | Preserves raw reports under `.workflow/executions/evidence/<plan-id>/` |
| **Git Safety** | Missing `.workflow/executions/evidence/` in `.gitignore` | Appends evidence ignore rule to `.gitignore` |
| **File References** | Old `.ar-wf/` paths or `ar-*` triggers in plan markdown/json | Stream-patches files to `.workflow/` and current skill names |
| **Skills Integrity** | Deprecated `ar-*` skills, obsolete `ultrawork`, broken frontmatter | Removes obsolete skills, verifies YAML frontmatter, fixes permissions |
| **Global Config Sync** | Out-of-date `hooks.json` or `AGENTS.md` in `~/.gemini/` | Synchronizes global config with latest canonical repository |

---

## Operating Modes

### 1. Audit Mode (Read-Only)
Inspects the active workspace and installed skills without touching any files:
```bash
./scripts/workflow-health-check.sh --check
```
Or for a specific workspace:
```bash
./scripts/workflow-health-check.sh --check --workspace="/path/to/project"
```
Returns exit code `0` if 100% compliant, or exit code `1` detailing all detected issues.

### 2. Auto-Repair Mode (`--fix`)
Autonomously resolves all detected issues, performing zero-data-loss migrations and syncing configurations:
```bash
./scripts/workflow-health-check.sh --fix
```
Or for a specific workspace:
```bash
./scripts/workflow-health-check.sh --fix --workspace="/path/to/project"
```

---

## When to Run

1. **New Device Setup**: Run immediately after cloning or pulling the configuration repository to ensure global skills in `~/.gemini/config/skills/` are fully synchronized and functional.
2. **Opening Legacy Projects**: When opening an existing codebase that still uses `.ar-wf/` or `.planning/`, run `/workflow-health-check` to seamlessly upgrade it to `.workflow/`.
3. **Broken Skill Recovery**: When an agent reports missing or broken skills (e.g. malformed frontmatter, missing execute permissions on shell helpers), run `/workflow-health-check` to validate and heal them.

---

## Agent Protocol

When this skill is triggered by the user:
1. Identify the target workspace (current working directory by default).
2. Execute `./scripts/workflow-health-check.sh --check --workspace="<target>"`:
   - If clean (exit 0): report full health compliance.
   - If issues found (exit 1): announce issues found, then execute `./scripts/workflow-health-check.sh --fix --workspace="<target>"`.
3. Verify that a re-run of `--check` exits with code 0.
4. Report the summary of resolved migrations to the user.
