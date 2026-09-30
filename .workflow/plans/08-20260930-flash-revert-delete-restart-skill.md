# Plan: Completely Revert and Delete the /restart Skill

- [x] **Step 1: Restore Original Binary and Remove Restart Scripts**
  - Move `/home/personal/.local/bin/agy.real` back to `/home/personal/.local/bin/agy` (restoring the raw Go binary).
  - Delete `scripts/agy-restart.sh` and `~/.gemini/config/scripts/agy-restart.sh`.
  - Delete `~/.gemini/antigravity-cli/.restart_signal` if present.
  - Verification: `file /home/personal/.local/bin/agy | grep -Fq "ELF" && ! test -f scripts/agy-restart.sh`

- [x] **Step 2: Delete Restart Skill Definitions**
  - Delete `config/skills/restart/` directory and remove it from installed global skills `~/.gemini/config/skills/restart/`.
  - Verification: `! test -d config/skills/restart && ! test -d ~/.gemini/config/skills/restart`

- [x] **Step 3: Clean Up References in Docs and Installers**
  - Remove `/restart` documentation and table row from `config/AGENTS.md` and `README.md`.
  - Remove any supervisor shim installation blocks from `install.sh` and `install.ps1`.
  - Verification: `! grep -Fq "restart" config/AGENTS.md && ! grep -Fq "agy.real" install.sh`

- [x] **Step 4: End-to-End Verification and Workflow Health Check**
  - Run `./scripts/workflow-health-check.sh --fix` and `./scripts/workflow-health-check.sh --check`.
  - Verification: `./scripts/workflow-health-check.sh --check`
