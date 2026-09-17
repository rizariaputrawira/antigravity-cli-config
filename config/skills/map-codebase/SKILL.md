---
name: map-codebase
description: >-
  Generates and maintains a comprehensive structural map of the codebase.
  Outputs 8 domain-specific documents to `.codebase-mapping/`. Runs 4 parallel
  specialized agents (tech, arch, quality, concerns) with CodeGraph/LSP indexing.
---

# Codebase Mapping Protocol

Generates a comprehensive structural and architectural map of the project via
4 parallel specialized agents. All output goes into `.codebase-mapping/`.

**Triggers:** '/map-codebase', 'map codebase', 'map out the project', 'map out codebase'

**Arguments (optional):**
- `--fast` — Skip parallel agents. Single agent produces STACK.md + ARCHITECTURE.md only.
- `--paths <dir>` — Restrict all agent scans to a specific directory (e.g. `--paths src/auth`).
- `--query <term>` — Search existing `.codebase-mapping/` intel without re-scanning.

## 1. Output Structure

All files live inside `.codebase-mapping/` at the active workspace root (e.g., if the user is working within a sub-project directory like `.source-code/boss-sfm`, place it there instead of the top-level git repository root):

### Tech Agent Output
- **`STACK.md`** — Languages, runtimes, frameworks, key dependencies, toolchain config.
- **`INTEGRATIONS.md`** — External APIs, databases, auth providers, webhooks, third-party services.

### Architecture Agent Output
- **`ARCHITECTURE.md`** — Patterns, layers, data flow, abstractions, entry points. MUST include at least one Mermaid.js diagram.
- **`STRUCTURE.md`** — Directory layout, key file locations, naming conventions.

### Quality Agent Output
- **`CONVENTIONS.md`** — Code style, naming patterns, error handling, PR conventions.
- **`TESTING.md`** — Test framework, file structure, mocking strategy, coverage posture.

### Concerns Agent Output
- **`CONCERNS.md`** — Tech debt, known bugs, security risks, performance bottlenecks, fragile areas.

### Synthesis (you write this after agents complete)
- **`CODE_INDEX.md`** — Exhaustive symbol index: core classes, primary functions, state management, and public exports — each linked to the exact file and line number (e.g. `[AuthService](src/auth/service.ts#L42)`).

## 2. Methodology

### Step 1 — Check `--query` mode
If `--query <term>` is passed: search existing `.codebase-mapping/` files for the term,
return matches as an Artifact, and **stop**. Do not re-scan.

### Step 2 — Ingest (Living Document Mode)
- If `.codebase-mapping/` exists, read the existing files first.
- Your goal is to update only what changed. Do not rewrite accurate sections.
- Track a `last_mapped` timestamp at the top of `CODE_INDEX.md` on every write.

### Step 3 — Check `--fast` mode
If `--fast` is passed: use a **single agent** to produce `STACK.md` and `ARCHITECTURE.md`
only. Skip the remaining agents. Jump to Step 5.

### Step 4 — Spawn 4 Parallel Domain Agents (default mode)
Always spawn exactly 4 parallel sub-agents via `invoke_subagent`, one per domain:

| Agent | Focus | Writes |
|---|---|---|
| Tech Agent | Tech stack & external integrations | `STACK.md`, `INTEGRATIONS.md` |
| Architecture Agent | Structure & data flow | `ARCHITECTURE.md`, `STRUCTURE.md` |
| Quality Agent | Conventions & testing | `CONVENTIONS.md`, `TESTING.md` |
| Concerns Agent | Debt, risks, fragile areas | `CONCERNS.md` |

**CRITICAL SCOPING RULE**: You MUST explicitly check the user's current active workspace directory (e.g., if they are working in a specific sub-project like `.source-code/boss-sfm`) and instruct each subagent to restrict their exploration and mapping *only* to that directory. Do not map the entire repository if the user is focused on a specific sub-project folder.

- Instruct each subagent to write their output directly into `.codebase-mapping/` inside that active sub-project directory (e.g., `.source-code/boss-sfm/.codebase-mapping/`).
- If `--paths <dir>` is provided, use that instead.
- Each agent explores thoroughly using `codegraph`, `lsp`, `ast-grep`, and `ripgrep`.
  If `codegraph`/`lsp` are unavailable, fall back to `ast-grep` + `ripgrep` and add a
  `> ⚠️ Generated without CodeGraph/LSP` callout at the top of affected files.

### Step 5 — Synthesize `CODE_INDEX.md`
After all agents complete (or in `--fast` mode, after the single agent), you write
`CODE_INDEX.md` yourself using the agents' findings plus direct CodeGraph/LSP queries
for the symbol index with line-accurate links. Place this file inside the same scoped `.codebase-mapping/` directory.

### Step 6 — Write
- Write or update all files inside the scoped `.codebase-mapping/` directory.
- Do NOT run `git commit`. Writing the files is sufficient.

## 3. Completion

Present a concise summary Artifact to the user covering:
- Which domains were mapped and by which mode (full/fast)
- Files written or updated
- Any gaps, unavailable tools, or areas flagged in `CONCERNS.md` that need immediate attention
