---
name: remember
description: >-
  Instantly appends critical project facts, constraints, or instructions directly into the
  AGENTS.md file so they are loaded as standing instructions for all future turns.
  Use when you or the user want to 'remember' a fact permanently for the project/session.
  Triggers: '/remember <note>', 'remember that...', 'add to memory'.
---

# /remember Skill

When this skill is invoked to remember a note:

1. Identify the target `AGENTS.md` file. By default, use the workspace rules (`.agents/AGENTS.md` or `AGENTS.md` in the current working directory). If the user explicitly asks to remember it "globally", target `~/.gemini/config/AGENTS.md`.
2. Append the exact note or fact as a bullet point at the bottom of the file under a `# Project Memory` header (create the header if it doesn't exist).
3. Do NOT use any internal RAG or memory tool — the write must go directly to the markdown file to ensure absolute cache-stability and 100% recall.
4. Report a brief confirmation to the user showing the exact path of the file that was updated.
