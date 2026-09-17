---
name: ar-brainstorm
description: >-
  You MUST use this before any creative work — creating features, building components,
  adding functionality, or modifying behavior. Explores user intent, requirements, and
  design before implementation (including Wayfinder Fog/Frontier decision mapping for complex/murky domains),
  and transitions seamlessly to ar-flashplan, ar-superplan, ar-hyperplan, and ar-hyperexecution.
  Triggers: '/ar-brainstorm', 'ar-brainstorm', 'brainstorm', 'brainstorming', '/ar-brainstorming', 'ar-brainstorming', 'design spec', 'explore ideas', 'wayfinder', '/wayfinder', 'fog map'.
---

# Brainstorming Ideas Into Designs

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by classifying how much process the request needs, then work
through your path: understand the context, refine the idea, present a
design, and get your human partner's approval.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any
project, or take any implementation action until you have told your
human partner what you intend and they have approved it. This applies
to EVERY task on EVERY path below — the ceremony scales with the task;
the approval gate never does.
</HARD-GATE>

## Three Paths

Before your first question, classify the request and say the
classification out loud — "this looks bounded, so I'll present a short
design here rather than write a spec" — so your human partner can
override it:

- **Spike** — a feasibility question ("can we...", "is it possible...",
  "quick and dirty is fine") whose output is an answer, not code you
  keep. Present the question and what you'll try in 2-3 sentences, get
  a nod, then find out as cheaply as correctness allows. No design
  doc, no spec file. Report findings as a recommendation; anything you
  built stays labeled throwaway.  
  *Transition*: If the spike proves feasible and your partner wants to build
  it for production, re-classify it as **Bounded** or **Architectural**.
- **Bounded** — a well-scoped change to code that already exists in
  this repo: a new flag, a small endpoint, a one-file fix.
  Understanding the kind of app is not enough — bounded means the flow
  you are changing is already here to read. If there is no existing
  flow to change, the task is not bounded. Ask the clarifying
  questions that matter, present a short design IN CHAT (a few
  sentences to a few short paragraphs), and STOP.  
  *Transition on approval*:
  - If it is a simple localized edit (≤1–2 files) and your partner approves: proceed with normal development (TDD applies).
  - If structured step-by-step tracking is desired (3–5 steps): launch `/ar-flashplan`.
  - If scope creeps into 2–6 files: escalate to `/ar-superplan`.
- **Architectural** — new projects, new subsystems, changes that
  restructure how components fit together or alter interfaces others
  depend on. Follow the full process: questions, approaches, sectioned
  design, written spec in `.ar-wf/planning/brainstorm/`, then transition to
  `/ar-superplan` (medium architecture) or `/ar-hyperplan` (complex/adversarial architecture),
  which feed directly into `/ar-hyperexecution` driven by `ar-ultrawork`.

When in doubt between two paths, take the heavier one. The ratchet is
one-way: hidden complexity discovered mid-task upgrades the path —
stop, say so, and step up. Nothing downgrades mid-task.

## Anti-Pattern: "Too Simple To Need Approval"

Every path ends with your human partner approving your intent before
implementation. A todo list, a single-function utility, a config
change — the design may be two sentences in chat, but you MUST present
it and get approval. "Simple" tasks are where unexamined assumptions
cause the most wasted work. What scales with simplicity is the
artifact, never the approval.

## Checklist

Classify first, announce the path, then create a task for each item on
your path and complete them in order.

**Spike:**
1. **Explore project context** — enough to frame the probe
2. **Present question + probe plan** — 2-3 sentences
3. **Get approval** — a nod is enough
4. **Investigate** — as cheaply as correctness allows
5. **Report findings** — a recommendation; label anything built as throwaway
6. **Graduate** — if keeping, classify as Bounded or Architectural and proceed

**Bounded:**
1. **Explore project context** — check files, docs, recent commits
2. **Ask clarifying questions** — one at a time, the ones that matter
3. **Present short design in chat** — approach, files touched, testing strategy
4. **Get approval** — STOP and wait for an explicit yes; presenting the design and starting in the same breath is skipping the gate
5. **Transition to implementation or planning**:
   - For simple direct changes: implement via standard TDD workflow.
    - For structured multi-step changes (3–5 steps): launch `/ar-flashplan`.
    - If scope exceeds 2 files: escalate to `/ar-superplan`.

**Architectural:**
1. **Explore project context** — check files, docs, recent commits
2. **Offer the visual companion just-in-time** — NOT upfront. Only when a question would genuinely be clearer shown than described.
3. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
4. **Propose 2-3 approaches** — with trade-offs and your recommendation
5. **Present design** — in sections scaled to their complexity, get user approval after each section
6. **Write design spec** — inspect `.ar-wf/planning/brainstorm/` to determine the next two-digit sequence `<SEQ>` (e.g. `01`, `02`). Save to `.ar-wf/planning/brainstorm/<SEQ>-YYYYMMDD-<kebab-case>-design.md` (e.g. `.ar-wf/planning/brainstorm/01-20260911-auth-flow-design.md`) and commit
7. **Spec self-review** — quick inline check for placeholders, contradictions, ambiguity, scope
8. **User reviews written spec** — ask user to review the spec file before proceeding
9. **Transition to planning**:
   - For medium systems (2–6 files, 5–10 steps): invoke `/ar-superplan` with the spec path.
   - For large/complex/adversarial architectures: invoke `/ar-hyperplan` with the spec path.
   - Plans persist to `.ar-wf/planning/<SEQ>-YYYYMMDD-<kebab-case>.md` and execute via `/ar-hyperexecution` (driven by `ar-ultrawork`).
---

## The Planning Triad Handoff

After Brainstorming reaches approval, route into the appropriate planning tier:
- **Bounded (Simple, 1-file)**: Direct standard TDD implementation.
- **Bounded (3–5 steps, 1–2 files)**: [`/ar-flashplan`](../ar-flashplan/SKILL.md) &rarr; `.ar-wf/planning/<SEQ>-YYYYMMDD-<kebab-case>.md`
- **Medium Architectural (5–10 steps, 2–6 files)**: [`/ar-superplan`](../ar-superplan/SKILL.md) (2 subagents) &rarr; `.ar-wf/planning/<SEQ>-YYYYMMDD-<kebab-case>.md`
- **Large Architectural (10+ steps)**: [`/ar-hyperplan`](../ar-hyperplan/SKILL.md) (5 subagents) &rarr; `.ar-wf/planning/<SEQ>-YYYYMMDD-<kebab-case>.md`

All plan files execute via **`/ar-hyperexecution`** driven by **`ar-ultrawork`** discipline.

---

## The Process

The subsections below serve the bounded and architectural paths (a
spike stops at "present the probe, get a nod"). Sections from
**Exploring approaches** onward are architectural-path depth — for
bounded work, context plus a few questions plus a short in-chat design
is the whole process.

**Understanding the idea:**

- Check out the current project state first (files, docs, recent commits).
- **Bounded Structural & Directory Discovery**:
  - Use `find_by_name` (capped at 50 results, respects `.gitignore`) or `list_dir` for directory exploration.
  - *Invariant*: Unbounded directory dumping via `directory_tree` is strictly prohibited in brainstorming to prevent context bloat.
- **Symbol & Flow Discovery**:
  - For existing codebases, query local MCP codegraph via `call_mcp_tool(ServerName="codegraph", ToolName="codegraph_explore", Arguments={"query": "<symbol/flow>", "projectPath": "<dir>"})` to discover symbols, call paths, and dependencies in a single round trip.
  - Or query local LSP symbol index via `call_mcp_tool(ServerName="lsp", ToolName="lsp_workspace_symbols", Arguments={"query": "<symbol_name>"})`.
  - *Invariant*: `lsp_definition` requires exact file, line, and character coordinates (`[file, line, character]`) and is NOT used for initial open-ended discovery.
  - If unindexed or tools are unavailable, immediately fall back to native `grep_search` and `view_file` (NEVER run `codegraph init` autonomously).
- Before asking detailed questions, assess scope: if the request describes multiple independent subsystems (e.g., "build a platform with chat, file storage, billing, and analytics"), flag this immediately. Don't spend questions refining details of a project that needs to be decomposed first.
- If the project is too large for a single spec, help the user decompose into sub-projects: what are the independent pieces, how do they relate, what order should they be built? Then brainstorm the first sub-project through the normal design flow. Each sub-project gets its own spec → plan → implementation cycle.
- For appropriately-scoped projects, ask questions one at a time to refine the idea
- Prefer multiple choice questions when possible, but open-ended is fine too
- Only one question per message - if a topic needs more exploration, break it into multiple questions
- Focus on understanding: purpose, constraints, success criteria

**Wayfinder Decision Mapping (For Foggy or Interdependent Domains):**

When exploring complex architectural domains where multiple design decisions depend on each other, or where the destination is foggy:
- Formulate an in-flight **Wayfinder Map**:
  - **Fog**: In-scope problem areas that cannot yet be phrased as precise questions. Keep visible; never silently guess.
  - **Blocked**: Questions whose answers depend on prior unresolved decisions (e.g. `Q-002 (Transport) depends on Q-001 (Data Model)`).
  - **Frontier**: Precise questions that have **zero unresolved dependencies**.
- *Invariant*: **Always ask questions strictly from the Frontier**, one at a time. Never ask a Blocked question prematurely.
- As each Frontier question is settled, move it to Completed, unlock any newly unblocked questions into the Frontier, and record the factual rationale in the design spec (`## Settled Decisions & Answers`).
- If invoked directly via `/wayfinder`, produce or maintain a Wayfinder Map (`MAP.md` sections: Frontier, Blocked, Fog, Settled) in chat or persist to `.ar-wf/planning/brainstorm/<SEQ>-YYYYMMDD-<kebab-case>-wayfinder.md` to map the terrain before drafting code.

**Exploring approaches:**

- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why
- YAGNI ruthlessly - remove unnecessary features from every approach and design

**Presenting the design:**

- Once you believe you understand what you're building, present the design
- Scale each section to its complexity: a few sentences if straightforward, up to 200-300 words if nuanced
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense

**Design for isolation and clarity:**

- Break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently
- For each unit, you should be able to answer: what does it do, how do you use it, and what does it depend on?
- Can someone understand what a unit does without reading its internals? Can you change the internals without breaking consumers? If not, the boundaries need work.
- Smaller, well-bounded units are also easier to work with — you reason better about code you can hold in context at once, and edits are more reliable when files are focused.

**Working in existing codebases:**

- Explore the current structure before proposing changes. Use bounded `find_by_name`, `list_dir`, and local MCP `codegraph_explore(query=..., projectPath=...)` or `lsp_workspace_symbols(query="...")` as the primary discovery tools for call hierarchies, symbols, and dependencies. If unindexed, immediately fall back to `grep_search` and `view_file`. Follow existing patterns.
- Where existing code has problems that affect the work (e.g., a file that's grown too large, unclear boundaries, tangled responsibilities), include targeted improvements as part of the design.
- Don't propose unrelated refactoring. Stay focused on what serves the current goal.

---

## After the Design (Architectural Path)

**Documentation:**

- Ensure directory exists: `mkdir -p .ar-wf/planning/brainstorm`
- Determine sequential identifier `<SEQ>`: Inspect `.ar-wf/planning/brainstorm/` for existing files matching `[0-9]{2}-*`, find the highest two-digit sequence, and increment by 1 (default `01` if empty or none).
- Write the validated design (spec) to `.ar-wf/planning/brainstorm/<SEQ>-YYYYMMDD-<kebab-case>-design.md` (e.g., `.ar-wf/planning/brainstorm/01-20260911-auth-service-design.md`), including architecture, components, and the Settled Decisions & Answers ledger.
- Filename must be strictly lowercase kebab-case.
- Commit the design document to git.

**Spec Self-Review:**
After writing the spec document, check:

1. **Placeholder scan:** Any "TBD", "TODO", incomplete sections, or vague requirements? Fix them.
2. **Internal consistency:** Do any sections contradict each other? Does the architecture match the feature descriptions?
3. **Scope check:** Is this focused enough for a single implementation plan, or does it need decomposition?
4. **Ambiguity check:** Could any requirement be interpreted two different ways? If so, pick one and make it explicit.

Fix any issues inline.

**User Review Gate:**
After the spec review passes, ask the user to review the written spec:

> "Spec written to `.ar-wf/planning/brainstorm/<SEQ>-YYYYMMDD-<kebab-case>-design.md`. Please review it and let me know if you'd like any changes before we generate the implementation plan."

Wait for the user's response. Proceed only once approved.

**Transition to Implementation Planning:**

- Invoke `/ar-superplan` (for medium architectures, 2–6 files) or `/ar-hyperplan` (for large/adversarial planning) passing the spec path.
- The resulting `.ar-wf/planning/<SEQ>-YYYYMMDD-<kebab-case>.md` checklist can then be executed relentlessly with `/ar-hyperexecution`.

---

## Visual Companion

A browser-based companion for showing mockups, diagrams, and visual options during brainstorming. Available as a tool — not a mode.

**Offering the companion (just-in-time):** Do NOT offer it upfront. Wait until a question would genuinely be clearer shown than told — a real mockup / layout / diagram question. Offer it as its own message:
> "This next part might be easier if I show you — I can put together mockups, diagrams, and comparisons in a browser tab as we go. Want me to open it for you?"

If they accept, start the server with `--open`. If they decline, continue text-only.
