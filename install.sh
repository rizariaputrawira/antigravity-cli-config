#!/usr/bin/env bash
# ==============================================================================
# Antigravity Configuration Installer (Linux & macOS)
# Supports both:
# 1. Local execution inside cloned repository
# 2. Remote pipe: curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh | bash
# ==============================================================================

set -euo pipefail

# Configurable defaults
DEFAULT_REPO="rizariaputrawira/antigravity-cli-config"
REPO_NAME="${ANTIGRAVITY_REPO:-$DEFAULT_REPO}"
TARGET_WORKSPACE="${WORKSPACE_DIR:-${HOME}/workspaces}"
DRY_RUN=false
TEMP_DIR=""

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --workspace=*)
      TARGET_WORKSPACE="${arg#*=}"
      shift
      ;;
    --repo=*)
      REPO_NAME="${arg#*=}"
      shift
      ;;
    --help|-h)
      echo "Antigravity Configuration Installer"
      echo "Usage: install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run              Simulate installation without touching ~/.gemini"
      echo "  --workspace=<path>     Set root workspace directory (default: ~/workspaces)"
      echo "  --repo=<owner/repo>    GitHub repository to download from when piped via curl"
      echo "  --help, -h             Show this help message"
      exit 0
      ;;
  esac
done

cleanup() {
  if [ -n "${TEMP_DIR}" ] && [ -d "${TEMP_DIR}" ]; then
    rm -rf "${TEMP_DIR}"
  fi
}
trap cleanup EXIT

echo "============================================================"
echo "⚡ Antigravity Portable Configuration Installer"
echo "============================================================"
echo "Workspace Root: ${TARGET_WORKSPACE}"
echo "Dry Run Mode:   ${DRY_RUN}"
echo ""

# 1. Determine Source Directory (Local repo vs Remote pipe)
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [ -n "${SCRIPT_DIR}" ] && [ -f "${SCRIPT_DIR}/config/AGENTS.md" ]; then
  SRC_DIR="${SCRIPT_DIR}"
  echo "📦 Source: Local repository at ${SRC_DIR}"
elif [ -f "./config/AGENTS.md" ]; then
  SRC_DIR="$(pwd)"
  echo "📦 Source: Local working directory at ${SRC_DIR}"
else
  echo "🌐 Source: Remote execution detected. Fetching repository archive from GitHub (${REPO_NAME})..."
  TEMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'antigravity-config')"
  ARCHIVE_URL="https://github.com/${REPO_NAME}/archive/refs/heads/main.tar.gz"
  
  if command -v curl >/dev/null 2>&1; then
    if ! curl -fsSL "${ARCHIVE_URL}" | tar -xz -C "${TEMP_DIR}" --strip-components=1 2>/dev/null; then
      echo "❌ Error: Failed to fetch archive from ${ARCHIVE_URL}." >&2
      echo "   Please ensure the GitHub repository exists and has a 'main' branch, or clone it locally." >&2
      exit 1
    fi
  elif command -v wget >/dev/null 2>&1; then
    if ! wget -qO- "${ARCHIVE_URL}" | tar -xz -C "${TEMP_DIR}" --strip-components=1 2>/dev/null; then
      echo "❌ Error: Failed to fetch archive from ${ARCHIVE_URL}." >&2
      exit 1
    fi
  else
    echo "❌ Error: Neither curl nor wget is available to download configuration archive." >&2
    exit 1
  fi
  SRC_DIR="${TEMP_DIR}"
fi

# 2. Pre-flight Environment Diagnostics
echo "🔍 Running pre-flight environment checks..."
MISSING_PREREQS=0

if ! command -v node >/dev/null 2>&1; then
  echo "  ⚠️ Warning: 'node' is not found in PATH. MCP servers and hooks require Node.js."
  MISSING_PREREQS=$((MISSING_PREREQS + 1))
else
  echo "  ✅ Node.js detected: $(node -v)"
fi

if ! command -v npx >/dev/null 2>&1; then
  echo "  ⚠️ Warning: 'npx' is not found in PATH. Context7, GitHub, and LSP MCP servers require npx."
  MISSING_PREREQS=$((MISSING_PREREQS + 1))
else
  echo "  ✅ npx detected: $(npx -v 2>/dev/null || echo 'available')"
fi

if ! command -v git >/dev/null 2>&1; then
  echo "  ⚠️ Warning: 'git' is not found in PATH."
  MISSING_PREREQS=$((MISSING_PREREQS + 1))
else
  echo "  ✅ git detected: $(git --version)"
fi

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "  💡 Notice: GITHUB_TOKEN is not currently exported. (GitHub MCP server requires this for auth)."
else
  echo "  ✅ GITHUB_TOKEN is present in environment."
fi

# 3. Target Directories & Non-Destructive Backup
GEMINI_DIR="${HOME}/.gemini"
CONFIG_DIR="${GEMINI_DIR}/config"
CLI_DIR="${GEMINI_DIR}/antigravity-cli"

if [ "${DRY_RUN}" = true ]; then
  echo ""
  echo "🔎 [DRY RUN] Would create directories:"
  echo "   - ${CONFIG_DIR}"
  echo "   - ${CLI_DIR}"
  echo "   - ${TARGET_WORKSPACE}"
  
  if [ -d "${CONFIG_DIR}" ]; then
    echo "🔎 [DRY RUN] Would backup existing ~/.gemini to ~/.gemini.bak.$(date +%Y%m%d_%H%M%S)"
  fi
  
  echo "🔎 [DRY RUN] Would render templates without sed -i:"
  echo "   - config.json.template -> ${CONFIG_DIR}/config.json (hostname: $(hostname))"
  echo "   - mcp_config.json.template -> ${CONFIG_DIR}/mcp_config.json (workspace: ${TARGET_WORKSPACE})"
  echo "   - settings.json.template -> ${CLI_DIR}/settings.json (if missing)"
  echo "🔎 [DRY RUN] Would copy skills ($(ls -1 "${SRC_DIR}/config/skills" 2>/dev/null | wc -l) skills), hooks, and AGENTS.md."
  echo ""
  echo "✅ Dry run completed successfully. Zero changes were made."
  exit 0
fi

echo ""
echo "🚀 Proceeding with installation..."

# Create backup if existing config directory exists
if [ -d "${CONFIG_DIR}" ] && [ "$(ls -A "${CONFIG_DIR}" 2>/dev/null)" ]; then
  BACKUP_DIR="${HOME}/.gemini.bak.$(date +%Y%m%d_%H%M%S)"
  echo "💾 Creating backup of existing configuration to ${BACKUP_DIR}..."
  mkdir -p "${BACKUP_DIR}"
  cp -r "${GEMINI_DIR}/config" "${BACKUP_DIR}/"
  [ -f "${CLI_DIR}/settings.json" ] && cp "${CLI_DIR}/settings.json" "${BACKUP_DIR}/" || true
fi

# Ensure target directories exist
mkdir -p "${CONFIG_DIR}" "${CLI_DIR}" "${TARGET_WORKSPACE}"

# 4. Template Rendering (Portable stream redirection, NO sed -i)
echo "⚙️ Rendering configuration templates..."

# Render config.json
HOSTNAME_VAL="$(hostname 2>/dev/null || echo 'localhost')"
sed "s|\${REMOTE_HOSTNAME}|${HOSTNAME_VAL}|g" \
  < "${SRC_DIR}/config/config.json.template" \
  > "${CONFIG_DIR}/config.json"

# Render mcp_config.json
sed "s|\${WORKSPACE_ROOT}|${TARGET_WORKSPACE}|g" \
  < "${SRC_DIR}/config/mcp_config.json.template" \
  > "${CONFIG_DIR}/mcp_config.json"

# Initialize settings.json only if not already present
if [ ! -f "${CLI_DIR}/settings.json" ]; then
  echo "⚙️ Initializing ${CLI_DIR}/settings.json..."
  sed "s|\"trustedWorkspaces\": \[\]|\"trustedWorkspaces\": [\"${TARGET_WORKSPACE}\"]|g" \
    < "${SRC_DIR}/settings/settings.json.template" \
    > "${CLI_DIR}/settings.json"
else
  echo "ℹ️ Existing settings.json preserved at ${CLI_DIR}/settings.json"
fi

# 5. Copy Static Assets
echo "📦 Copying global rules, hooks, and skills..."
cp "${SRC_DIR}/config/AGENTS.md" "${CONFIG_DIR}/AGENTS.md"
cp "${SRC_DIR}/config/hooks.json" "${CONFIG_DIR}/hooks.json"

# Copy skills
mkdir -p "${CONFIG_DIR}/skills"
cp -r "${SRC_DIR}/config/skills/"* "${CONFIG_DIR}/skills/"

echo ""
echo "============================================================"
echo "🎉 Antigravity configuration successfully installed!"
echo "============================================================"
echo "Global Config: ${CONFIG_DIR}"
echo "Skills Count:  $(ls -1 "${CONFIG_DIR}/skills" 2>/dev/null | wc -l)"
echo ""
echo "You can now run 'agy' or 'antigravity' in your terminal."
