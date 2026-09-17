# ⚡ Antigravity CLI Configuration (Portable Dotfiles)

A complete, battle-tested, portable configuration distribution for [Google Antigravity CLI](https://github.com/google-deepmind) (`agy`).

This repository packages:
- 🧠 **Global Rules & Workflows**: The `oh-my-antigravity` framework, Ponytail minimization heuristics, atomic commits, and host safety protocols.
- 🛠️ **29 Custom Skills**: Advanced planning suites (`ar-ultrawork`, `ar-hyperplan`, `ar-superplan`, `ar-flashplan`, `ar-hyperexecution`, `ar-brainstorm`), code quality audits (`tech-debt-audit`, `security-research`), debugging tools (`systematic-debugging`, `test-driven-development`), and system administration (`linux-sysadmin`, `podman-operator`, `bash-scripting`).
- 🔌 **5 Built-in MCP Servers**: Pre-configured stdio integrations for `context7`, `github`, `filesystem`, `codegraph`, and `lsp`.
- 🛡️ **Lifecycle Hooks**: Automated git command safety guards (`git-safety`), comment hygiene, and session banner notifications.
- ⚡ **Optimized Performance Settings**: Pre-configured execution policies (`always-proceed`), artifact review (`agent-decides`), and pinned model tier.

---

## 🚀 Quick Install (One-Liner)

Install on any clean machine in seconds without needing to clone the repository first:

### Linux & macOS (Bash / Zsh)
```bash
curl -fsSL https://raw.githubusercontent.com/<username>/antigravity-config/main/install.sh | bash
```

*With custom workspace directory:*
```bash
curl -fsSL https://raw.githubusercontent.com/<username>/antigravity-config/main/install.sh | bash -s -- --workspace=/path/to/workspaces
```

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/<username>/antigravity-config/main/install.ps1 | iex
```

*With custom workspace directory:*
```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/<username>/antigravity-config/main/install.ps1))) -Workspace "D:\workspaces"
```

---

## 💻 Local Installation (Cloned Repo)

If you have cloned this repository locally:

### Linux & macOS:
```bash
git clone https://github.com/<username>/antigravity-config.git ~/antigravity-config
cd ~/antigravity-config
chmod +x install.sh
./install.sh
```

### Windows:
```powershell
git clone https://github.com/<username>/antigravity-config.git $HOME\antigravity-config
cd $HOME\antigravity-config
.\install.ps1
```

### Testing Without Making Changes (Dry Run):
- **Linux/macOS**: `./install.sh --dry-run`
- **Windows**: `.\install.ps1 -DryRun`

---

## 🛡️ Non-Destructive Backup & Safety

The installer is **fully non-destructive and idempotent**:
1. If an existing `~/.gemini/config` directory is found, it is automatically snapshotted to a timestamped backup:
   `~/.gemini.bak.YYYYMMDD_HHMMSS/`
2. An existing `~/.gemini/antigravity-cli/settings.json` is preserved to ensure your personal workspace list and active tokens are never overwritten.
3. Zero tokens, conversation histories, or private credentials are included in this repository.

---

## 📋 Prerequisites

- **Antigravity CLI**: `agy` binary installed on system path (`~/.local/bin/agy` or `antigravity`).
- **Node.js & npx** (v18+): Required for MCP tool servers (`context7`, `github`, `lsp`, `codegraph`).
- **GitHub Token** *(Optional)*: Export `GITHUB_TOKEN="your_personal_access_token"` in your `~/.bashrc`, `~/.zshrc`, or Windows Environment Variables for GitHub MCP integration.

---

## 📁 Repository Structure

```text
antigravity-config/
├── .gitignore                      # Hardened quarantine for tokens, logs, databases
├── README.md                       # This documentation
├── install.sh                      # Zero-dependency dual-mode Linux/macOS installer
├── install.ps1                     # Native Windows PowerShell installer
├── config/                         # Portable global configurations (~/.gemini/config/)
│   ├── AGENTS.md                   # Global agent rules (oh-my-antigravity)
│   ├── config.json.template        # Base config with dynamic hostname injection
│   ├── mcp_config.json.template    # Base MCP config with parameterized workspace path
│   ├── hooks.json                  # Validated, syntax-fixed lifecycle hooks
│   ├── hooks/                      # General lifecycle hook scripts
│   └── skills/                     # All 29 custom skills (sanitized of hardcoded paths)
├── settings/                       # App settings (~/.gemini/antigravity-cli/)
│   └── settings.json.template      # Pinned models & permissions with empty trustedWorkspaces
├── integrations/                   # Optional third-party integrations
│   └── herdr/
│       └── herdr-agent-state.sh
└── templates/
    └── workspace-agents/           # Starter .agents/ template for new projects
```

---

## 🔄 Updating Your Devices

When you push improvements or new custom skills to your GitHub repository, update any device with:

```bash
# On Linux / macOS
curl -fsSL https://raw.githubusercontent.com/<username>/antigravity-config/main/install.sh | bash

# On Windows
irm https://raw.githubusercontent.com/<username>/antigravity-config/main/install.ps1 | iex
```
