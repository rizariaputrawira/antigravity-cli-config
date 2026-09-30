#!/usr/bin/env bash
# ==============================================================================
# agy-restart.sh — Antigravity CLI Seamless Session Restarter
# Signals the parent agy process to exit and triggers the outer shell wrapper
# to immediately re-launch: agy -c (or specified args).
# ==============================================================================

set -euo pipefail

MODE="restart"
RESTART_ARGS="-c"
SIGNAL_DIR="${HOME}/.gemini/antigravity-cli"
SIGNAL_FILE="${SIGNAL_DIR}/.restart_signal"

for arg in "$@"; do
  case "$arg" in
    --check)
      MODE="check"
      shift
      ;;
    --dry-run)
      MODE="dry-run"
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
    --help|-h)
      echo "Usage: $(basename "$0") [--check|--dry-run|--fresh|--continue]"
      echo ""
      echo "Options:"
      echo "  --check     Verify agy PID discovery and signal file path without signaling"
      echo "  --dry-run   Simulate writing restart signal without terminating agy"
      echo "  --continue  Restart and continue the active conversation (default: -c)"
      echo "  --fresh     Restart with a fresh conversation session"
      exit 0
      ;;
  esac
done

# 1. Locate parent agy PID by traversing process tree
find_agy_pid() {
  local curr=$$
  while [ "$curr" -gt 1 ]; do
    local comm
    comm="$(ps -p "$curr" -o comm= 2>/dev/null || true)"
    if [ "$comm" = "agy" ] || [ "$comm" = "antigravity" ]; then
      echo "$curr"
      return 0
    fi
    curr="$(ps -p "$curr" -o ppid= 2>/dev/null | tr -d ' ' || true)"
    [ -z "$curr" ] && break
  done

  # Fallback: scan current user's processes for agy
  pgrep -u "$(id -u)" -x agy 2>/dev/null | head -n 1 || true
}

AGY_PID="$(find_agy_pid)"

if [ "$MODE" = "check" ]; then
  echo "🔍 Antigravity Session Restart Diagnostics"
  echo "  Signal Path: ${SIGNAL_FILE}"
  if [ -n "${AGY_PID}" ]; then
    echo "  Parent AGY:  Found (PID ${AGY_PID})"
    exit 0
  else
    echo "  Parent AGY:  None detected (running outside active agy session)"
    exit 0
  fi
fi

# Ensure signal directory exists
mkdir -p "${SIGNAL_DIR}"

if [ "$MODE" = "dry-run" ]; then
  echo "🔍 [DRY RUN] Would write restart flag '${RESTART_ARGS}' to ${SIGNAL_FILE}"
  if [ -n "${AGY_PID}" ]; then
    echo "🔍 [DRY RUN] Would signal SIGTERM to agy PID ${AGY_PID}"
  else
    echo "⚠️ [DRY RUN] No active agy PID detected to terminate."
  fi
  exit 0
fi

# 2. Write restart signal
echo "${RESTART_ARGS}" > "${SIGNAL_FILE}"

echo ""
echo "============================================================"
echo "🔄 Restarting Antigravity CLI session (${RESTART_ARGS:-fresh})..."
echo "============================================================"
echo ""

if [ -n "${AGY_PID}" ]; then
  # Graceful termination of parent agy
  kill -TERM "${AGY_PID}" 2>/dev/null || kill -9 "${AGY_PID}" 2>/dev/null || true
else
  echo "⚠️ Note: Could not detect parent agy PID."
  echo "   Signal file created at ${SIGNAL_FILE}."
  echo "   Please exit current session (Ctrl+D) and run: agy -c"
fi
