# Plan: Immediate Synchronous Process Termination for /restart

- [x] **Step 1: Restore Direct Synchronous Termination in `scripts/agy-restart.sh`**
  - Remove the broken `sleep 0.5` subshell that gets reaped before firing; send `kill -TERM "${AGY_PID}"` directly and immediately so `agy.real` terminates on the spot and the active supervisor shim reloads `agy.real -c`.
  - Also sync to `~/.gemini/config/scripts/agy-restart.sh`.
  - Verification: `bash -n scripts/agy-restart.sh && ./scripts/agy-restart.sh --check`

- [x] **Step 2: Workflow Health Check Verification**
  - Run `./scripts/workflow-health-check.sh --check` to prove clean compliance.
  - Verification: `./scripts/workflow-health-check.sh --check`
