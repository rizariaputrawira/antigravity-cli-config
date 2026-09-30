# Plan: Robust Session Restart via Executable Shim

- [x] **Step 1: Clean Up Dotfiles & Update Installers**
  - Remove `agy()` shell functions from `~/.bashrc`, `~/.zshrc`, `install.sh`, and `install.ps1` to eliminate fragile RC profile dependency.
  - Verification: `! grep -Fq "agy() {" ~/.bashrc && ! grep -Fq "agy() {" install.sh`

- [x] **Step 2: Deploy Executable Shim & Streamline Restart Helper**
  - Move raw Go binary to `/home/personal/.local/bin/agy.real` and deploy a 20-line crash-guarded wrapper script at `/home/personal/.local/bin/agy`.
  - Streamline `scripts/agy-restart.sh` by stripping unused flags down to the essential PID signaling.
  - Verification: `test -x /home/personal/.local/bin/agy.real && /home/personal/.local/bin/agy --version && bash -n scripts/agy-restart.sh`

- [x] **Step 3: End-to-End Verification & Health Check**
  - Run `./scripts/workflow-health-check.sh --fix` and verify `--check` exits with 0.
  - Verification: `./scripts/workflow-health-check.sh --check`

