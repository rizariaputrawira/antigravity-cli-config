# Plan: Asynchronous Restart Signaling for Seamless Session Reload

- [x] **Step 1: Add Asynchronous Signal Delay to `scripts/agy-restart.sh`**
  - Update `scripts/agy-restart.sh` to decouple the termination signal with `(sleep 0.5 && kill -TERM "${AGY_PID}") & disown` so the current agent turn and tool response complete cleanly before `agy.real` exits.
  - Also ensure `~/.gemini/config/scripts/agy-restart.sh` is synchronized.
  - Verification: `bash -n scripts/agy-restart.sh && ./scripts/agy-restart.sh --check`

- [x] **Step 2: Verify Supervisor Shim Active Binding & Health Check**
  - Verify that the active session is running under the supervisor shim (`bash /home/personal/.local/bin/agy -c`), and run `./scripts/workflow-health-check.sh --check`.
  - Verification: `ps -fp $(pgrep -u "$(id -u)" -x "agy.real" | head -n 1) | grep -Fq "agy" && ./scripts/workflow-health-check.sh --check`
