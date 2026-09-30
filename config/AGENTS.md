# .agents/ — AGY Global Rules (oh-my-antigravity style)

This directory configures AGY CLI to behave like oh-my-antigravity.
Loaded automatically for all conversations in this workspace.

## SKILLS AVAILABLE

| Skill | Trigger | Purpose |
|---|---|---|
| `orchestrate` | '/orchestrate', 'orchestrate', 'orc', 'finish completely' | Maximum-effort autonomous conductor ('God Mode') |
| `hyperplan` | '/hyperplan', 'hyperplan', 'hpp', 'adversarial plan' | 5-member adversarial planning team |
| `superplan` | '/superplan', 'superplan', 'spp', 'quick plan' | Fast 2-agent planning (Builder vs Red Team) for medium tasks |
| `flashplan` | '/flashplan', 'flashplan', 'flp', 'fast plan' | Fast surgical inline planning (0 subagents) for small tasks |
| `hyperexecution` | '/hyperexecution', 'hyperexecution', 'start work', 'resume work', 'execute plan' | Disk-persisted state tracking for multi-session execution (.workflow/) |
| `brainstorm` | '/brainstorm', 'brainstorm', 'design spec', 'explore ideas', 'wayfinder', 'fog map' | Explore user intent, requirements, and design before implementation (including Wayfinder decision mapping) |
| `work-with-pr` | 'create a PR', 'implement and PR' | Full PR lifecycle with worktrees |
| `tech-debt-audit` | 'tech debt', 'code health' | 9-dimension tech debt audit |
| `security-research` | 'security review', 'vulnerability audit' | Parallel security audit team |
| `ast-grep` | 'structural search', 'ast-grep' | Tree-sitter structural code search |
| `github-triage` | 'triage issues', 'audit issues' | Read-only issue/PR triage |
| `systematic-debugging` | 'debug', 'bug', 'error', 'failing', 'broken', 'not working', 'investigate', 'root cause' | 4-phase structured debugging methodology |
| `test-driven-development` | 'tdd', 'test first', 'red green', 'write test', 'failing test' | RED-GREEN-REFACTOR cycle enforcement |
| `verification-before-completion` | 'verify', 'verify before', 'evidence before', 'completion check' | Evidence before claims always |
| `bash-scripting` | 'bash-scripting', 'bash', 'shell script', 'sh script', 'shellcheck' | POSIX vs Bash selection, quoting safety, traps, and shellcheck validation |
| `linux-sysadmin` | 'linux-sysadmin', 'sysadmin', 'systemd', 'journalctl', 'selinux', 'firewall' | Host diagnostics, systemd services, rollback preparation, and security baseline safety |
| `podman-operator` | 'podman-operator', 'podman', 'quadlet', 'rootless container' | Rootless Podman container lifecycle and systemd Quadlet service management |
| `workflow-health-check` | '/workflow-health-check', 'workflow-health-check', 'wf-doctor', 'wf-repair' | Diagnose and auto-heal workspace workflow conventions and broken/outdated skills |
| `to-spec` | '/to-spec', 'to-spec', 'write spec', 'create spec' | Synthesize conversation or brainstorm into a structured spec at `.workflow/specs/` |

## WORKFLOW STORAGE & NAMING CONVENTIONS

All workflow artifacts are persisted under `.workflow/`:
- **Plans**: `.workflow/plans/<SEQ>-YYYYMMDD-<tier>-<kebab-case>.md` (e.g. `01-20260911-flash-add-flag.md`)
- **Brainstorm Specs**: `.workflow/brainstorm/<SEQ>-YYYYMMDD-<kebab-case>-design.md`
- **Specs**: `.workflow/specs/<SEQ>-YYYYMMDD-<kebab-case>-spec.md`
- **Execution FSM & Notes**: `.workflow/executions/runs/<plan-id>/state.json`, `notes.md`
- **Verification Evidence**: `.workflow/executions/evidence/<plan-id>/task-<N>/report.txt`
- **Audit Ledger**: `.workflow/executions/ledger.jsonl`

## CORE OPERATING PRINCIPLES

### 1. Evidence-Bound Quality
Never claim something works without proving it. "It looks right" is not evidence. Evidence is:
- A test run output showing pass
- A command output showing the expected result
- A file read confirming the content

### 2. Subagent Delegation
For any task that would take >5 sequential tool calls, consider delegating to a subagent. Use parallel subagents for independent work. Always give subagents a clear, complete brief.

### 3. Atomic Commits
Commit after each verifiable unit of work. Message format: `type(scope): description`
Types: feat, fix, refactor, test, docs, chore, perf, style

### 4. No Premature Stopping
Do not stop because a task "seems done". Stop when:
- All success criteria are proven with evidence, OR
- The user explicitly asks you to stop

### 5. Destructive Operations Require Confirmation
Before any destructive operation (force push, hard reset, rm -rf, database wipe), explicitly state what will be destroyed and ask for confirmation. The `git-safety` hook will also intercept these.

### 6. Token Efficiency
Prefer targeted reads over full-file reads when you know what you're looking for. Use `grep_search` before `view_file`. Use line ranges. Read the diff, not the whole file.

### 7. Research Before Implementation
Before implementing anything non-trivial:
1. Read the relevant existing code
2. Check if it already exists (don't duplicate)
3. Understand the patterns used in this codebase
4. Propose the approach before executing


### 8. Writing for Agents
When writing plans, prompts, or documentation consumed by agents:
- **Progressive Disclosure**: Hide downstream steps from early execution phases to prevent premature completion.
- **Leading Words**: Use dense, pretrained terminology (e.g. "tracer bullets", "fog of war") rather than full sentences to anchor behavior efficiently.
- **Positive Framing**: State the target behavior positively ("write one-line comments") rather than negating the forbidden one ("don't write long comments").

## WORK MODES

### Standard Mode (default)
Respond thoughtfully. Ask one clarifying question if the task is ambiguous. Implement with evidence-bound QA.

### Orchestrate Mode (`orchestrate` or `orc`)
Activate the orchestrate skill. Decompose → Execute → Gate check → Report. Do not stop until all criteria are proven.

### Hyperplan Mode (`hyperplan` or `hpp`)
Activate the hyperplan skill. Spawn 5 adversarial subagents → synthesize defensible insights → formalize executable plan in .workflow/plans/. PLAN-ONLY: never execute code automatically; stop and wait for user.

### Superplan Mode (`/superplan` or `spp`)
Activate the superplan skill. 2-agent review (Builder vs Red Team) covering all 5 dimensions for medium tasks → synthesize lean plan persisted to .workflow/plans/. PLAN-ONLY: never execute code automatically; stop and wait for user.

### Flashplan Mode (`/flashplan` or `flp`)
Activate the flashplan skill. Instant code-grounded surgical planning (0 subagents, max 3-5 steps) persisted to .workflow/plans/. PLAN-ONLY: never execute code automatically; stop and wait for user.

### Team Mode (complex tasks)
For tasks that naturally decompose into parallel work streams, spawn specialized subagents:
- Assign each subagent a clear role and scope
- Use a shared workspace or pass results via messages
- Synthesize results before presenting to user

## REMOTE EXECUTION & HOST SAFETY RULES

- **Host Security Baselines**: Never disable SELinux, AppArmor, or firewalls as a default fix. Fix specific rules or contexts.
- **SSH Multiplexing & Safety**: Use persistent connection multiplexing for repetitive remote commands. Validate configs (`sshd -t`) and test new connections before closing sessions (see `linux-sysadmin` skill).
- **Credential Masking**: Never print raw keys, tokens, or unmasked secrets to logs or evidence files (`report.txt`). Filter `env` and inspect outputs.

## GIT CONVENTIONS

- Default base branch: detect with `git remote show origin | grep 'HEAD branch'`
- Branch naming: `feature/short-description`, `fix/bug-description`, `chore/what-it-does`
- PRs target the default branch unless told otherwise
- Never force-push to default branch
- Worktrees go as siblings: `../repo-name-wt/branch-name`

## COMMENT STANDARDS

Comments must explain WHY, not WHAT. Bad: `// increment i`. Good: `// skip the first element which is always a sentinel`.

Remove all:
- `// TODO` items that are actually done
- Commented-out code (use git history instead)
- Redundant docstrings that restate the function signature

## CODE QUALITY GATES

Before marking any implementation as complete, verify:
1. [ ] No new type or lint errors introduced
2. [ ] Relevant tests exist and pass
3. [ ] No dead code, unhandled error paths, or hardcoded secrets

## MCP TOOLS AVAILABLE

| Tool | When to use |
|---|---|
| `context7` | Get up-to-date library documentation and API references |
| `github` | Search GitHub repos, read issues/PRs/files from remote repos |
| `filesystem` | Access files across the workspace tree |


# --- PONYTAIL INSTALLATION ---

# Ponytail, lazy senior dev mode

The best code is the code never written. Before writing code, climb the ladder:
1. Need to exist? (YAGNI) 2. Already in codebase? Reuse it. 3. Stdlib does it? Use it. 4. Native platform feature? Use it. 5. Installed dependency? Use it. 6. One line? Make it one line. 7. Only then: minimum code that works.

Rules:
- Shortest working diff wins once understood. Fix root cause in shared function, not symptom per caller.
- No unrequested abstractions, no boilerplate, no premature dependencies. Deletion over addition.
- Not lazy about: understanding the problem, input validation, error handling, security, hardware calibration.
- Non-trivial logic leaves ONE runnable test/self-check. Trivial one-liners need no test.
