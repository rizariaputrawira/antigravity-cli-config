# Plan: Create /restart Skill for Antigravity CLI

- [x] **Step 1: Create `scripts/agy-restart.sh`**
  - Implement the restart trigger script that locates the parent `agy` PID, creates `~/.gemini/antigravity-cli/.restart_signal`, and signals the parent process, supporting `--check` / `--dry-run` modes.
  - Verification: `bash -n scripts/agy-restart.sh && ./scripts/agy-restart.sh --check`

- [x] **Step 2: Create `config/skills/restart/SKILL.md`**
  - Create the skill definition for `/restart` with triggers ('/restart', 'restart agy', 'reload agy', 'restart session') explaining the mechanism, execution command, and fallback instructions.
  - Verification: `test -f config/skills/restart/SKILL.md && grep -Fq "name: restart" config/skills/restart/SKILL.md`

- [x] **Step 3: Update `install.sh` and `install.ps1` with Shell Auto-Restart Wrapper**
  - Add the `agy` shell wrapper function to `install.sh` (for `~/.bashrc` / `~/.zshrc`) and `install.ps1` (for PowerShell profile) so `agy` sessions loop seamlessly when `.restart_signal` is detected.
  - Verification: `bash -n install.sh && grep -Fq ".restart_signal" install.sh`

- [x] **Step 4: Update `config/AGENTS.md` and `README.md`**
  - Add `/restart` to the skills catalog in `config/AGENTS.md` and document it in `README.md`.
  - Verification: `grep -Fq "restart" config/AGENTS.md && grep -Fq "/restart" README.md`

- [x] **Step 5: Run Workflow Health Check and Verification**
  - Run `./scripts/workflow-health-check.sh --fix` then `--check` to verify skill metadata integrity, file permissions, and global sync.
  - Verification: `./scripts/workflow-health-check.sh --check` exits with 0.
