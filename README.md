# ⚡ Antigravity CLI Configuration (Portable Dotfiles)

A complete, battle-tested, portable configuration distribution for [Google Antigravity CLI](https://github.com/google-deepmind) (`agy`).

This repository packages:
- 🧠 **Global Rules & Workflows**: The `oh-my-antigravity` framework, Ponytail minimization heuristics, atomic commits, and host safety protocols.
- 🛠️ **30 Custom Skills**: Advanced planning suites (`orchestrate`, `hyperplan`, `superplan`, `flashplan`, `hyperexecution`, `brainstorm`, `to-spec`, `workflow-health-check`), code quality audits (`tech-debt-audit`, `security-research`), debugging tools (`systematic-debugging`, `test-driven-development`), and system administration (`linux-sysadmin`, `podman-operator`, `bash-scripting`).
- 🔌 **5 Built-in MCP Servers**: Pre-configured stdio integrations for `context7`, `github`, `filesystem`, `codegraph`, and `lsp`.
- 🛡️ **Lifecycle Hooks**: Automated git command safety guards (`git-safety`) and session banner notifications.
- ⚡ **Optimized Performance Settings**: Pre-configured execution policies (`always-proceed`), artifact review (`agent-decides`), and pinned model tier.

---

## 🚀 Quick Install (One-Liner)

Install on any clean machine in seconds without needing to clone the repository first:

### Linux & macOS (Bash / Zsh)
```bash
curl -fsSL https://raw.githubusercontent.com/rizariaputrawira/antigravity-cli-config/main/install.sh | bash
```

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/rizariaputrawira/antigravity-cli-config/main/install.ps1 | iex
```

---

## 💻 Local Installation (Cloned Repo)

If you have cloned this repository locally:

### Linux & macOS:
```bash
git clone https://github.com/rizariaputrawira/antigravity-cli-config.git ~/antigravity-config
cd ~/antigravity-config
chmod +x install.sh
./install.sh
```

### Windows:
```powershell
git clone https://github.com/rizariaputrawira/antigravity-cli-config.git $HOME\antigravity-config
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
├── scripts/                        # Maintenance and utility scripts
│   └── workflow-health-check.sh    # Workspace migration and skills auto-repair tool
├── config/                         # Portable global configurations (~/.gemini/config/)
│   ├── AGENTS.md                   # Global agent rules (oh-my-antigravity)
│   ├── config.json.template        # Base config with dynamic hostname injection
│   ├── mcp_config.json.template    # Base MCP config with parameterized workspace path
│   ├── hooks.json                  # Validated, syntax-fixed lifecycle hooks
│   ├── hooks/                      # General lifecycle hook scripts
│   └── skills/                     # All 29 custom skills (sanitized of hardcoded paths)
└── settings/                       # App settings (~/.gemini/antigravity-cli/)
    └── settings.json.template      # Pinned models & permissions with empty trustedWorkspaces
```

---


## 🧠 Autonomous Planning & Orchestration

This configuration ships with a robust **Multi-Tier Orchestration Architecture** to manage autonomous agent lifecycles, ensuring rigorous validation and preventing hallucinations or infinite loops.

For a comprehensive guide on how the planning, execution, and state-tracking mechanisms (`/flashplan`, `/superplan`, `/hyperplan`, `/hyperexecution`, and `/orchestrate`) interact, see the [Planning & Execution Workflow Guide](docs/PLANNING_GUIDE.md).

The full canonical pipeline is: **`/brainstorm`** → **`/to-spec`** → **`/superplan`** or **`/hyperplan`** → **`/hyperexecution`**. After a brainstorm session, run `/to-spec` to crystallize the approved design into a structured spec at `.workflow/specs/`; then pass the spec path directly to a planning skill (e.g. `/superplan .workflow/specs/01-…-spec.md`). Each stage is optional — you can also plan directly from chat context without a prior brainstorm or spec.

## 🩺 Workflow Health Check & Auto-Repair

When switching devices, pulling updates, or working in projects created under legacy conventions (`.ar-wf/`, `.planning/`, deprecated `ar-*` skills), run `/workflow-health-check` or the automated CLI tool:

```bash
# Audit workspace and skills (read-only audit):
./scripts/workflow-health-check.sh --check

# Automatically heal and migrate to latest conventions:
./scripts/workflow-health-check.sh --fix
```

---

## 🔄 Updating Your Devices

When you push improvements or new custom skills to your GitHub repository, update any device with:

```bash
# On Linux / macOS
curl -fsSL https://raw.githubusercontent.com/rizariaputrawira/antigravity-cli-config/main/install.sh | bash

# On Windows
irm https://raw.githubusercontent.com/rizariaputrawira/antigravity-cli-config/main/install.ps1 | iex
```
