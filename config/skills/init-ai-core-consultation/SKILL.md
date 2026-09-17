---
name: init-ai-core-consultation
description: Enforces that the agent reads and grounds its answers in the workspace's AI Core (wiki/) before proceeding with tasks related to SFD, Viya, or SFM.
---

# Init AI Core Consultation

**Triggers:** `/init-ai-core-consultation`, 'consult the core', 'check ai core', 'read the wiki'

## Purpose
This skill ensures that before beginning any architectural planning, code migration, rule authoring, or answering domain-specific questions, the agent first consults the project's central knowledge base (`wiki/ai-core-index.md`). It guarantees that all actions strictly adhere to documented standards rather than assumptions.

## Execution Steps
1. **Locate the Core (and Remember it)**: 
   - First, check if the absolute path to the AI core is already saved in the project's `AGENTS.md`. If it is, use that absolute path directly.
   - If not, check the current directory for `wiki/ai-core-index.md`. If not found, walk up the parent directories (`../`, `../../`) until you locate the true project root AI core.
   - **Crucial:** Once you find it by walking up, immediately append the absolute path to the project's `AGENTS.md` file (using the `/remember` behavior) so the project permanently remembers where the core is for all future agent interactions.
2. **Identify Relevant Domains**: Based on the user's request, identify which domains (`client-sfd`, `sfd-official`, etc.) hold the necessary specifications.
3. **Deep Dive**: Use your search tools (`grep_search`, `find_by_name`, or `cat`) within that located `wiki/` directory to extract the exact documents containing the required specs, schemas, or rule syntaxes.
4. **Grounding Invariant Enforcement**: 
   - Never guess or hallucinate SFD (Boss Viya) capabilities, payload shapes, or legacy SFM behaviors.
   - All implementation details must be strictly cited from the `wiki/`.
   - If required specs are missing, explicitly inform the user and request they be added to the `raw/` and `wiki/` knowledge base.
5. **Acknowledge & Plan**: Inform the user that the AI Core has been consulted, list the specific wiki documents you read, and outline how they apply to the task at hand before executing.
