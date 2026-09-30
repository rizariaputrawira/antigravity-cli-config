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

## Usage

```bash
# Read-only audit (exit 0 if healthy, 1 if issues found)
./scripts/workflow-health-check.sh --check [--workspace="/path/to/project"]

# Auto-repair (migrates legacy dirs, patches references, repairs skills)
./scripts/workflow-health-check.sh --fix [--workspace="/path/to/project"]
```

---

## Agent Protocol

When this skill is triggered by the user:
1. Identify the target workspace (current working directory by default).
2. Execute `./scripts/workflow-health-check.sh --check --workspace="<target>"`:
   - If clean (exit 0): report full health compliance.
   - If issues found (exit 1): announce issues found, then execute `./scripts/workflow-health-check.sh --fix --workspace="<target>"`.
3. Verify that a re-run of `--check` exits with code 0.
4. Report the summary of resolved migrations to the user.
