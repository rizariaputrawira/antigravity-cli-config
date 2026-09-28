# Execution Notes: 01-20260928-workflow-health-check

## Decisions
- Create `scripts/workflow-health-check.sh` as a zero-dependency Bash script supporting inspection (`--check`), auto-migration (`--fix`), and workspace targeting (`--workspace=<path>`).
- Check and migrate both:
  1. Workspace workflow directories (`.ar-wf` -> `.workflow`, `planning` -> `plans`, brainstorm un-nesting, `runs/<plan-id>` restructuring, `evidence` directory preservation).
  2. Skills health: identify broken `ar-*` prefixes, deprecated `ultrawork`, verify frontmatter `name`/`description`, fix script permissions, and sync out-of-date global configs.
- Register skill `workflow-health-check` in `config/skills/workflow-health-check/SKILL.md` and reference in `config/AGENTS.md` and `README.md`.

## Issues

## Learnings

## Blockers
