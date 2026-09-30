---
name: restart
description: >-
  Gracefully restarts the active Antigravity CLI process and immediately resumes with 'agy -c'.
  Use to reload newly installed skills, updated MCP tools, modified rules, or clear TUI state.
  Triggers: '/restart', 'restart agy', 'reload agy', 'restart session'.
---

# Restart Antigravity CLI (`/restart`)

Gracefully terminates the current `agy` session and triggers an immediate reload with `agy -c` (resuming the most recent conversation) using the outer shell auto-restart wrapper.

---

## When to Use

1. **Reload Skills & MCP Servers**: After installing, updating, or modifying skills, MCP configs (`mcp_config.json`), or hooks that require a process reload to take effect.
2. **Clear UI Stalls**: When the terminal UI becomes unresponsive or garbled.
3. **Session Refresh**: To refresh runtime memory while preserving conversational continuity.

---

## Execution Protocol

When triggered:
1. Ensure all active file edits and disk state (`.workflow/`) are saved.
2. Execute the restart script:
   ```bash
   ./scripts/agy-restart.sh --continue
   ```
   *(Or if running in a consumer project outside this repo: `~/.gemini/config/scripts/agy-restart.sh --continue`)*
3. The helper script:
   - Sets the restart flag `~/.gemini/antigravity-cli/.restart_signal`.
   - Sends a `SIGTERM` to the parent `agy` process.
4. The outer shell wrapper (`agy()` in `~/.bashrc` / `~/.zshrc` / PowerShell `$PROFILE`) catches the signal and automatically launches `agy -c`.

> **Note**: If the outer shell wrapper is not installed, the script will exit cleanly and inform the user to type `agy -c` (or run `./install.sh` to install the wrapper).
