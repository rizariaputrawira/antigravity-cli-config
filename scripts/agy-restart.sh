#!/usr/bin/env bash
# ==============================================================================
# agy-restart.sh — Antigravity CLI Session Restarter
# Signals the active agy process to exit and triggers the supervisor shim
# to immediately re-launch: agy -c
# ==============================================================================

set -euo pipefail

SIGNAL_DIR="${HOME}/.gemini/antigravity-cli"
SIGNAL_FILE="${SIGNAL_DIR}/.restart_signal"
RESTART_ARGS="-c"
CHECK_ONLY=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --check)
      CHECK_ONLY=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --fresh|--new)
      RESTART_ARGS=""
      shift
      ;;
    --continue)
      RESTART_ARGS="-c"
      shift
      ;;
  esac
done

find_agy_pid() {
  local curr=$$
  while [ "$curr" -gt 1 ]; do
    local comm
    comm="$(ps -p "$curr" -o comm= 2>/dev/null || true)"
    if [ "$comm" = "agy.real" ] || [ "$comm" = "agy" ] || [ "$comm" = "antigravity" ]; then
      echo "$curr"
      return 0
    fi
    curr="$(ps -p "$curr" -o ppid= 2>/dev/null | tr -d ' ' || true)"
    [ -z "$curr" ] && break
  done
  pgrep -u "$(id -u)" -x "agy.real" 2>/dev/null | head -n 1 || pgrep -u "$(id -u)" -x "agy" 2>/dev/null | head -n 1 || true
}

AGY_PID="$(find_agy_pid)"

if [ "$CHECK_ONLY" = true ]; then
  echo "🔍 Antigravity Session Restart Diagnostics"
  echo "  Signal Path: ${SIGNAL_FILE}"
  echo "  Target PID:  ${AGY_PID:-None detected}"
  exit 0
fi

mkdir -p "${SIGNAL_DIR}"

if [ "$DRY_RUN" = true ]; then
  echo "🔍 [DRY RUN] Would write restart flag '${RESTART_ARGS}' to ${SIGNAL_FILE}"
  echo "🔍 [DRY RUN] Would signal SIGTERM to PID ${AGY_PID:-none}"
  exit 0
fi

echo "${RESTART_ARGS}" > "${SIGNAL_FILE}"

echo "============================================================"
echo "🔄 Restarting Antigravity CLI session (${RESTART_ARGS:-fresh})..."
echo "============================================================"

if [ -n "${AGY_PID}" ]; then
  # Delay termination by 0.5s in background subshell so active tool execution finishes cleanly
  (sleep 0.5 && kill -TERM "${AGY_PID}" 2>/dev/null || true) & disown
  echo "  ✅ Scheduled graceful termination for PID ${AGY_PID} (in 500ms)..."
else
  echo "⚠️ Note: Could not detect parent agy process PID."
  echo "   Signal file created at ${SIGNAL_FILE}."
  echo "   Please exit current session (Ctrl+D) to trigger supervisor reload."
fi
